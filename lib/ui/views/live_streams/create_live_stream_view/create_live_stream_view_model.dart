import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/time.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/extensions/custom_date_time_extensions.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/url_handler.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreateLiveStreamViewModel extends BaseViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  DialogService? _dialogService = locator<DialogService>();
  PlatformDataService? _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService? _locationService = locator<LocationService>();
  FirestoreStorageService? _firestoreStorageService = locator<FirestoreStorageService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  StripeConnectAccountService? _stripeConnectAccountService = locator<StripeConnectAccountService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();

  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///STREAM DATE CONTROLLERS
  TextEditingController startDateTextController = TextEditingController();
  TextEditingController endDateTextController = TextEditingController();

  ///HELPERS
  bool initialized = false;
  bool textFieldEnabled = true;
  bool loadedPreviousTitle = false;
  bool loadedPreviousDescription = false;
  bool loadedPreviousVenueName = false;
  bool loadedPreviousFBUsername = false;
  bool loadedPreviousInstaUsername = false;
  bool loadedPreviousTwitterUsername = false;
  bool loadedPreviousTwitchUsername = false;
  bool loadedPreviousYoutube = false;
  bool loadedPreviousWebsite = false;
  bool loadedPreviousFBStreamKey = false;
  bool loadedPreviousTwitchStreamKey = false;
  bool loadedPreviousYoutubeStreamKey = false;

  ///USER DATA
  bool? hasEarningsAccount;

  ///STREAM DATA
  bool isEditing = false;
  bool isDuplicate = false;

  ///FILE DATA
  File? fileToUpload;

  WebblenLiveStream stream = WebblenLiveStream();

  ///FORMATTERS
  //Date & Time Details
  DateTime selectedDateTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
  );

  DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  DateFormat timeFormatter = DateFormat('h:mm a');
  DateFormat dateTimeFormatter = DateFormat('MMM dd, yyyy h:mm a');
  DateTime selectedStartDate = DateTime.now();
  DateTime? selectedEndDate;

  ///WEBBLEN CURRENCY
  double? newStreamTaxRate;
  double? promo;

  ///INITIALIZE
  initialize(String id, double promo) async {
    setBusy(true);

    //generate new event
    stream = WebblenLiveStream().generateNewWebblenLiveStream(hostID: user.id!, suggestedUIDs: []);

    //check if user has earnings account
    hasEarningsAccount = await _stripeConnectAccountService!.isStripeConnectAccountSetup(user.id);

    //set timezone
    stream.timezone = getCurrentTimezone();
    stream.startTime = timeFormatter.format(DateTime.now().add(Duration(hours: 1)).roundDown(delta: Duration(minutes: 30)));
    stream.endTime = timeFormatter.format(DateTime.now().add(Duration(hours: 2)).roundDown(delta: Duration(minutes: 30)));
    notifyListeners();

    //check for promos & if editing/duplicating existing stream
    if (id.contains("duplicate_")) {
      id = id.replaceAll("duplicate_", "");
      stream = await _liveStreamDataService.getStreamByID(id);
      if (stream.isValid()) {
        stream.id = getRandomString(32);
        stream.attendees = {};
        stream.savedBy = [];
        stream.muxStreamID = null;
        stream.muxAssetDuration = null;
        stream.muxAssetPlaybackID = null;
        stream.muxStreamKey = null;
        isDuplicate = true;
      }
    } else if (id != "new") {
      stream = await _liveStreamDataService.getStreamByID(id);
      if (stream.isValid()) {
        startDateTextController.text = stream.startDate!;
        endDateTextController.text = stream.endDate!;
        selectedStartDate = dateFormatter.parse(stream.startDate!);
        selectedEndDate = dateFormatter.parse(stream.endDate!);
        isEditing = true;
      }
    } else {
      await setPreviousSocialData();
    }

    //get webblen rates
    newStreamTaxRate = await _platformDataService!.getNewStreamTaxRate();
    if (newStreamTaxRate == null) {
      newStreamTaxRate = 0.05;
    }

    //complete initialization
    initialized = true;

    notifyListeners();
    setBusy(false);
  }

  ///PREVIOUS SOCIAL DATA
  setPreviousSocialData() async {
    //fb
    stream.fbUsername = await _userDataService.getCurrentFbUsername(user.id!);
    stream.fbStreamKey = await _userDataService.getCurrentUserFBStreamKey(user.id!);

    //insta
    stream.instaUsername = await _userDataService.getCurrentInstaUsername(user.id!);

    //twitter
    stream.twitterUsername = await _userDataService.getCurrentTwitterUsername(user.id!);

    //twitch
    stream.twitchUsername = await _userDataService.getCurrentTwitchUsername(user.id!);
    stream.twitchStreamKey = await _userDataService.getCurrentUserTwitchStreamKey(user.id!);

    //website
    stream.website = await _userDataService.getCurrentUserWebsite(user.id!);

    //youtube
    stream.youtube = await _userDataService.getCurrentYoutube(user.id!);
    stream.youtubeStreamKey = await _userDataService.getCurrentUserYoutubeStreamKey(user.id!);
  }

  ///LOAD PREVIOUS DATA
  String loadPreviousTitle() {
    String val = "";
    if (!loadedPreviousTitle) {
      val = stream.title ?? "";
    }
    loadedPreviousTitle = true;
    notifyListeners();
    return val;
  }

  String loadPreviousDesc() {
    String val = "";
    if (!loadedPreviousDescription) {
      val = stream.description ?? "";
    }
    loadedPreviousDescription = true;
    notifyListeners();
    return val;
  }

  String loadPreviousFBUsername() {
    String val = "";
    if (!loadedPreviousFBUsername) {
      val = stream.fbUsername ?? "";
    }
    loadedPreviousFBUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousInstaUsername() {
    String val = "";
    if (!loadedPreviousInstaUsername) {
      val = stream.instaUsername ?? "";
    }
    loadedPreviousInstaUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousTwitterUsername() {
    String val = "";
    if (!loadedPreviousTwitterUsername) {
      val = stream.twitterUsername ?? "";
    }
    loadedPreviousTwitterUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousTwitchUsername() {
    String val = "";
    if (!loadedPreviousTwitchUsername) {
      val = stream.twitchUsername ?? "";
    }
    loadedPreviousTwitchUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousYoutubeChannel() {
    String val = "";
    if (!loadedPreviousYoutube) {
      val = stream.youtube ?? "";
    }
    loadedPreviousYoutube = true;
    notifyListeners();
    return val;
  }

  String loadPreviousWebsite() {
    String val = "";
    if (!loadedPreviousWebsite) {
      val = stream.website ?? "";
    }
    loadedPreviousWebsite = true;
    notifyListeners();
    return val;
  }

  String loadPreviousFBStreamKey() {
    String val = "";
    if (!loadedPreviousFBStreamKey) {
      val = stream.fbStreamKey ?? "";
    }
    loadedPreviousFBStreamKey = true;
    notifyListeners();
    return val;
  }

  String loadPreviousTwitchStreamKey() {
    String val = "";
    if (!loadedPreviousTwitchStreamKey) {
      val = stream.twitchStreamKey ?? "";
    }
    loadedPreviousTwitchStreamKey = true;
    notifyListeners();
    return val;
  }

  String loadPreviousYoutubeStreamKey() {
    String val = "";
    if (!loadedPreviousYoutubeStreamKey) {
      val = stream.youtubeStreamKey ?? "";
    }
    loadedPreviousYoutubeStreamKey = true;
    notifyListeners();
    return val;
  }

  ///HOW TO FIND STREAM KEYS
  showHowToFindStreamKeys() {
    UrlHandler().launchInWebViewOrVC("https://www.webblen.io/post/getting-started-stream-to-twitch-youtube-and-facebook");
  }

  ///STREAM IMAGE
  selectImage() async {
    String? source = await _customBottomSheetService.showImageSelectorBottomSheet();
    if (source != null) {
      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (source == "camera") {
        bool hasCameraPermission = await _permissionHandlerService.hasCameraPermission();
        if (hasCameraPermission) {
          fileToUpload = await WebblenImagePicker().retrieveImageFromCamera(ratioX: 1, ratioY: 1);
        } else {
          if (Platform.isAndroid) {
            _customDialogService.showAppSettingsDialog(
              title: "Camera Permission Required",
              description: "Please open your app settings and enable your camera",
            );
          }
        }
      } else if (source == "gallery") {
        bool hasPhotosPermission = await _permissionHandlerService.hasPhotosPermission();
        if (hasPhotosPermission) {
          fileToUpload = await WebblenImagePicker().retrieveImageFromLibrary(ratioX: 1, ratioY: 1);
        } else {
          if (Platform.isAndroid) {
            _customDialogService.showAppSettingsDialog(
              title: "Storage Permission Required",
              description: "Please open your app settings and enable your access to your storage",
            );
          }
        }
      }

      //wait a bit to re-enable text fields
      await Future.delayed(Duration(milliseconds: 500));
      textFieldEnabled = true;
      notifyListeners();
    }
  }

  ///STREAM INFO
  updateTitle(String val) {
    stream.title = val;
    notifyListeners();
  }

  updateDescription(String val) {
    stream.description = val;
    notifyListeners();
  }

  onSelectedPrivacyFromDropdown(String val) {
    stream.privacy = val;
    notifyListeners();
  }

  ///STREAM LOCATION
  Future<bool> updateLocation(Map<String, dynamic> details) async {
    bool success = true;
    setBusy(true);
    if (details.isEmpty) {
      return false;
    }

    //set nearest zipcodes
    stream.nearbyZipcodes = await _locationService!.findNearestZipcodes(details['areaCode']);
    if (stream.nearbyZipcodes == null) {
      setBusy(false);
      return false;
    }

    //set lat
    stream.lat = details['lat'];

    //set lon
    stream.lon = details['lon'];

    //set address
    stream.audienceLocation = details['streetAddress'];

    //set city
    stream.city = details['cityName'];

    //get province
    stream.province = details['province'];

    notifyListeners();
    setBusy(false);
    return success;
  }

  ///EVENT DATA & TIME
  selectDate({required bool selectingStartDate}) async {
    //set selectable dates
    Map<String, dynamic> customData = selectingStartDate
        ? {'minSelectedDate': DateTime.now().subtract(Duration(days: 1)), 'selectedDate': selectedStartDate}
        : {'minSelectedDate': selectedStartDate, 'selectedDate': selectedEndDate ?? selectedStartDate};
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      title: selectingStartDate ? "Start Date" : "End Date",
      data: customData,
      barrierDismissible: true,
      variant: BottomSheetType.calendar,
    );
    if (sheetResponse != null) {
      //format selected date
      DateTime selectedDate = sheetResponse.data;
      String formattedDate = dateFormatter.format(selectedDate);

      //set start date
      if (selectingStartDate) {
        selectedStartDate = selectedDate;
        stream.startDate = formattedDate;
        startDateTextController.text = formattedDate;
      }
      //set end date
      if (!selectingStartDate || selectedEndDate == null) {
        selectedEndDate = selectedDate;
        stream.endDate = formattedDate;
        endDateTextController.text = formattedDate;
      }
      notifyListeners();
    }
  }

  onSelectedTimeFromDropdown({required bool selectedStartTime, required String time}) {
    if (selectedStartTime) {
      stream.startTime = time;
    } else {
      stream.endTime = time;
    }
    notifyListeners();
  }

  onSelectedTimezoneFromDropdown(String val) {
    stream.timezone = val;
    notifyListeners();
  }

  ///ADDITIONAL STREAM INFO
  updateSponsorshipStatus(bool val) {
    stream.openToSponsors = val;
    notifyListeners();
  }

  updateFBUsername(String val) {
    stream.fbUsername = val.trim();
    notifyListeners();
  }

  updateInstaUsername(String val) {
    stream.instaUsername = val.trim();
    notifyListeners();
  }

  updateTwitterUsername(String val) {
    stream.twitterUsername = val.trim();
    notifyListeners();
  }

  updateTwitchUsername(String val) {
    stream.twitchUsername = val.trim();
    notifyListeners();
  }

  updateYoutube(String val) {
    stream.youtube = val.trim();
    notifyListeners();
  }

  updateWebsite(String val) {
    stream.website = val.trim();
    notifyListeners();
  }

  updateYoutubeStreamKey(String val) {
    stream.youtubeStreamKey = val.trim();
    notifyListeners();
  }

  updateTwitchStreamKey(String val) {
    stream.twitchStreamKey = val.trim();
    notifyListeners();
  }

  updateFBStreamKey(String val) {
    stream.fbStreamKey = val.trim();
    notifyListeners();
  }

  ///FORM VALIDATION
  bool titleIsValid() {
    return isValidString(stream.title);
  }

  bool descIsValid() {
    return isValidString(stream.description);
  }

  bool audienceLocationIsValid() {
    return isValidString(stream.audienceLocation);
  }

  bool startDateIsValid() {
    bool isValid = isValidString(stream.startDate);
    if (isValid) {
      String eventStartDateAndTime = stream.startDate! + " " + stream.startTime!;
      stream.startDateTimeInMilliseconds = dateTimeFormatter.parse(eventStartDateAndTime).millisecondsSinceEpoch;
      notifyListeners();
    }
    return isValid;
  }

  bool endDateIsValid() {
    bool isValid = isValidString(stream.endDate);
    if (isValid) {
      String eventEndDateAndTime = stream.endDate! + " " + stream.endTime!;
      stream.endDateTimeInMilliseconds = dateTimeFormatter.parse(eventEndDateAndTime).millisecondsSinceEpoch;
      notifyListeners();
      if (stream.endDateTimeInMilliseconds! < stream.startDateTimeInMilliseconds!) {
        isValid = false;
      }
    }
    return isValid;
  }

  bool fbUsernameIsValid() {
    return isValidUsername(stream.fbUsername!);
  }

  bool instaUsernameIsValid() {
    return isValidUsername(stream.instaUsername!);
  }

  bool twitterUsernameIsValid() {
    return isValidUsername(stream.twitterUsername!);
  }

  bool twitchUsernameIsValid() {
    return isValidUsername(stream.twitchUsername!);
  }

  bool websiteIsValid() {
    return isValidUrl(stream.website!);
  }

  bool formIsValid() {
    bool isValid = false;
    if (fileToUpload == null && stream.imageURL == null) {
      _customDialogService.showErrorDialog(description: "Image required");
    } else if (!titleIsValid()) {
      _customDialogService.showErrorDialog(description: "Title required");
    } else if (!descIsValid()) {
      _customDialogService.showErrorDialog(description: "Description required");
    } else if (!audienceLocationIsValid()) {
      _customDialogService.showErrorDialog(description: "Audience location required");
    } else if (!startDateIsValid()) {
      _customDialogService.showErrorDialog(description: "Stream start date required");
    } else if (!endDateIsValid()) {
      _customDialogService.showErrorDialog(description: "Stream end date required");
    } else if (stream.fbUsername != null && stream.fbUsername!.isNotEmpty && !fbUsernameIsValid()) {
      _customDialogService.showErrorDialog(description: "Facebook username is invalid");
    } else if (stream.instaUsername != null && stream.instaUsername!.isNotEmpty && !instaUsernameIsValid()) {
      _customDialogService.showErrorDialog(description: "Instagram username is invalid");
    } else if (stream.twitterUsername != null && stream.twitterUsername!.isNotEmpty && !twitterUsernameIsValid()) {
      _customDialogService.showErrorDialog(description: "Twitter username is invalid");
    } else if (stream.twitchUsername != null && stream.twitchUsername!.isNotEmpty && !twitchUsernameIsValid()) {
      _customDialogService.showErrorDialog(description: "Twitch username is invalid");
    } else if (stream.website != null && stream.website!.isNotEmpty && !websiteIsValid()) {
      _customDialogService.showErrorDialog(description: "Website URL is invalid");
    } else if (stream.youtube != null && stream.youtube!.isNotEmpty && !websiteIsValid()) {
      _customDialogService.showErrorDialog(description: "Youtube URL is invalid");
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<bool> submitStream() async {
    bool success = true;

    //upload img if exists
    if (fileToUpload != null) {
      String? imageURL = await _firestoreStorageService!.uploadImage(img: fileToUpload!, storageBucket: 'images', folderName: 'streams', fileName: stream.id!);
      if (imageURL == null) {
        _customDialogService.showErrorDialog(description: "There was an issue uploading your stream. Please try again.");
        return false;
      }
      stream.imageURL = imageURL;
    }

    //set suggested uids for event
    stream.suggestedUIDs = stream.suggestedUIDs == null ? user.followers : stream.suggestedUIDs;

    //upload stream data
    var uploadResult;
    if (isEditing) {
      uploadResult = await _liveStreamDataService.updateStream(stream: stream);
    } else {
      uploadResult = await _liveStreamDataService.createStream(stream: stream);
    }

    if (uploadResult is String) {
      _customDialogService.showErrorDialog(description: "There was an issue uploading your stream. Please try again.");
      return false;
    }

    //cache username data
    await saveSocialData();
    return success;
  }

  saveSocialData() async {
    if (isValidString(stream.fbUsername)) {
      await _userDataService.updateFbUsername(id: stream.hostID!, val: stream.fbUsername!);
    }
    if (isValidString(stream.instaUsername)) {
      await _userDataService.updateInstaUsername(id: stream.hostID!, val: stream.instaUsername!);
    }
    if (isValidString(stream.twitterUsername)) {
      await _userDataService.updateTwitterUsername(id: stream.hostID!, val: stream.twitterUsername!);
    }
    if (isValidString(stream.twitchUsername)) {
      await _userDataService.updateTwitchUsername(id: stream.hostID!, val: stream.twitchUsername!);
    }
    if (isValidString(stream.youtube)) {
      await _userDataService.updateYoutube(id: stream.hostID!, val: stream.youtube!);
    }
    if (isValidString(stream.youtubeStreamKey)) {
      await _userDataService.updateYoutubeStreamKey(id: stream.hostID!, val: stream.youtubeStreamKey!);
    }
    if (isValidString(stream.twitchStreamKey)) {
      await _userDataService.updateTwitchStreamKey(id: stream.hostID!, val: stream.twitchStreamKey!);
    }
    if (isValidString(stream.fbStreamKey)) {
      await _userDataService.updateFBStreamKey(id: stream.hostID!, val: stream.fbStreamKey!);
    }
  }

  submitForm() async {
    setBusy(true);
    //submit new stream
    bool submitted = await submitStream();
    if (submitted) {
      //show bottom sheet
      displayUploadSuccessBottomSheet();
    }
    setBusy(false);
  }

  showNewContentConfirmationBottomSheet({required BuildContext context}) async {
    FocusScope.of(context).unfocus();
    setBusy(true);
    //exit function if form is invalid
    if (!formIsValid()) {
      setBusy(false);
      return;
    }

    //check if editing post
    if (isEditing) {
      submitForm();
      return;
    }

    //display event confirmation
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      title: "Schedule Stream?",
      description: stream.privacy == "Public" ? "Schedule this stream for everyone to see" : "Your stream ready to be scheduled and shared",
      mainButtonTitle: "Schedule Stream",
      secondaryButtonTitle: "Cancel",
      customData: {'fee': newStreamTaxRate, 'promo': promo},
      variant: BottomSheetType.newContentConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;

      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (res == "insufficient funds") {
        setBusy(false);
        _customDialogService.showErrorDialog(description: "Insufficient funds");
      } else if (res == "confirmed") {
        submitForm();
      } else {
        setBusy(false);
      }

      //wait a bit to re-enable text fields
      await Future.delayed(Duration(milliseconds: 500));
      textFieldEnabled = true;
      notifyListeners();
    }
  }

  displayUploadSuccessBottomSheet() async {
    //deposit and/or withdraw webblen & promo
    if (promo != null) {
      _userDataService.depositWebblen(uid: user.id!, amount: promo!);
    }
    _userDataService.withdrawWebblen(uid: user.id, amount: newStreamTaxRate!);

    //display success
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
        variant: BottomSheetType.addContentSuccessful,
        takesInput: false,
        customData: stream,
        barrierDismissible: false,
        title: isEditing ? "Your Stream has been Updated" : "Your Stream has been Scheduled! 🎉");

    if (sheetResponse == null || sheetResponse.responseData == "done") {
      _customNavigationService.navigateToBase();
    }
  }

  ///NAVIGATION
  navigateBack() async {
    bool confirmed = false;
    if (isEditing) {
      confirmed = await _customBottomSheetService.showCancelEditingContentBottomSheet();
    } else {
      confirmed = await _customBottomSheetService.showCancelCreatingContentBottomSheet(content: stream);
    }
    if (confirmed) {
      _customNavigationService.navigateToBase();
    }
  }

  navigateBackToWalletPage() async {
    DialogResponse? response = await _dialogService!.showDialog(
      title: "Create an Earnings Account?",
      description: isEditing ? "Changes to this stream will not be saved" : "The details for this stream will not be saved",
      cancelTitle: "Continue Editing",
      cancelTitleColor: appTextButtonColor(),
      buttonTitle: "Create Earnings Account",
      buttonTitleColor: appTextButtonColor(),
      barrierDismissible: true,
    );
    if (response != null && response.confirmed) {
      _customNavigationService.navigateToWalletView();
    }
  }
}
