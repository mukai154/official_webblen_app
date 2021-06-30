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
  SnackbarService? _snackbarService = locator<SnackbarService>();
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

  ///STREAM DETAILS CONTROLLERS
  TextEditingController tagTextController = TextEditingController();
  TextEditingController titleTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();
  TextEditingController startDateTextController = TextEditingController();
  TextEditingController endDateTextController = TextEditingController();
  TextEditingController instaUsernameTextController = TextEditingController();
  TextEditingController fbUsernameTextController = TextEditingController();
  TextEditingController twitterUsernameTextController = TextEditingController();
  TextEditingController twitchTextController = TextEditingController();
  TextEditingController youtubeTextController = TextEditingController();
  TextEditingController websiteTextController = TextEditingController();
  TextEditingController fbStreamKeyTextController = TextEditingController();
  TextEditingController twitchStreamKeyTextController = TextEditingController();
  TextEditingController youtubeStreamKeyTextController = TextEditingController();

  ///HELPERS
  bool initialized = false;
  bool textFieldEnabled = true;

  ///USER DATA
  bool? hasEarningsAccount;

  ///STREAM DATA
  bool isEditing = false;
  bool isDuplicate = false;
  File? img;

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
        prepopulateFields();
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
        await setPreviousSocialData();
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
    String fbUsername = await _userDataService.getCurrentFbUsername(user.id!);
    String fbStreamKey = await _userDataService.getCurrentUserFBStreamKey(user.id!);
    fbUsernameTextController.text = fbUsername;
    fbStreamKeyTextController.text = fbStreamKey;
    stream.fbUsername = fbUsername;
    stream.fbStreamKey = fbStreamKey;

    //insta
    instaUsernameTextController.text = await _userDataService.getCurrentInstaUsername(user.id!);

    //twitter
    twitterUsernameTextController.text = await _userDataService.getCurrentTwitterUsername(user.id!);

    //twitch
    String twitchUsername = await _userDataService.getCurrentTwitchUsername(user.id!);
    String twitchStreamKey = await _userDataService.getCurrentUserTwitchStreamKey(user.id!);
    twitchTextController.text = twitchUsername;
    twitchStreamKeyTextController.text = twitchStreamKey;
    stream.twitchUsername = twitchUsername;
    stream.twitchStreamKey = twitchStreamKey;

    //website
    websiteTextController.text = await _userDataService.getCurrentUserWebsite(user.id!);

    //youtube
    String youtubeChannelLink = await _userDataService.getCurrentYoutube(user.id!);
    String youtubeStreamKey = await _userDataService.getCurrentUserYoutubeStreamKey(user.id!);
    youtubeTextController.text = youtubeChannelLink;
    youtubeStreamKeyTextController.text = youtubeStreamKey;
    stream.youtube = youtubeChannelLink;
    stream.youtubeStreamKey = youtubeStreamKey;
  }

  prepopulateFields() {
    titleTextController.text = stream.title!;
    descTextController.text = stream.description!;
    startDateTextController.text = stream.startDate!;
    endDateTextController.text = stream.endDate!;
    fbUsernameTextController.text = stream.fbUsername == null ? "" : stream.fbUsername!;
    instaUsernameTextController.text = stream.instaUsername == null ? "" : stream.instaUsername!;
    twitterUsernameTextController.text = stream.twitterUsername == null ? "" : stream.twitterUsername!;
    websiteTextController.text = stream.website == null ? "" : stream.website!;
    twitchTextController.text = stream.twitchUsername == null ? "" : stream.twitchUsername!;
    youtubeTextController.text = stream.youtube == null ? "" : stream.youtube!;
    fbStreamKeyTextController.text = stream.fbStreamKey == null ? "" : stream.fbStreamKey!;
    twitchStreamKeyTextController.text = stream.twitchStreamKey == null ? "" : stream.twitchStreamKey!;
    youtubeStreamKeyTextController.text = stream.youtubeStreamKey == null ? "" : stream.youtubeStreamKey!;
    selectedStartDate = dateFormatter.parse(stream.startDate!);
    selectedEndDate = dateFormatter.parse(stream.endDate!);
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
          img = await WebblenImagePicker().retrieveImageFromCamera(ratioX: 1, ratioY: 1);
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
          img = await WebblenImagePicker().retrieveImageFromLibrary(ratioX: 1, ratioY: 1);
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

  ///STREAM TAGS
  addTag(String tag) {
    List tags = stream.tags == null ? [] : stream.tags!.toList(growable: true);

    //check if tag already listed
    if (!tags.contains(tag)) {
      //check if tag limit has been reached
      if (tags.length == 3) {
        _snackbarService!.showSnackbar(
          title: 'Tag Limit Reached',
          message: 'You can only add up to 3 tags for your stream',
          duration: Duration(seconds: 5),
        );
      } else {
        //add tag
        tags.add(tag);
        stream.tags = tags;
        notifyListeners();
      }
    }
    tagTextController.clear();
  }

  removeTagAtIndex(int index) {
    List tags = stream.tags == null ? [] : stream.tags!.toList(growable: true);
    tags.removeAt(index);
    stream.tags = tags;
    notifyListeners();
  }

  ///STREAM INFO
  setStreamTitle(String val) {
    stream.title = val;
    notifyListeners();
  }

  setStreamDescription(String val) {
    stream.description = val;
    notifyListeners();
  }

  onSelectedPrivacyFromDropdown(String val) {
    stream.privacy = val;
    notifyListeners();
  }

  ///STREAM LOCATION
  Future<bool> setStreamAudienceLocation(Map<String, dynamic> details) async {
    bool success = true;

    if (details.isEmpty) {
      return false;
    }

    //set nearest zipcodes
    stream.nearbyZipcodes = await _locationService!.findNearestZipcodes(details['areaCode']);
    if (stream.nearbyZipcodes == null) {
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
  setSponsorshipStatus(bool val) {
    stream.openToSponsors = val;
    notifyListeners();
  }

  setFBUsername(String val) {
    stream.fbUsername = val.trim();
    notifyListeners();
  }

  setInstaUsername(String val) {
    stream.instaUsername = val.trim();
    notifyListeners();
  }

  setTwitterUsername(String val) {
    stream.twitterUsername = val.trim();
    notifyListeners();
  }

  setTwitchUsername(String val) {
    stream.twitchUsername = val.trim();
    notifyListeners();
  }

  setYoutube(String val) {
    stream.youtube = val.trim();
    notifyListeners();
  }

  setWebsite(String val) {
    stream.website = val.trim();
    notifyListeners();
  }

  setYoutubeStreamKey(String val) {
    stream.youtubeStreamKey = val.trim();
    notifyListeners();
  }

  setTwitchStreamKey(String val) {
    stream.twitchStreamKey = val.trim();
    notifyListeners();
  }

  setFBStreamKey(String val) {
    stream.fbStreamKey = val.trim();
    notifyListeners();
  }

  ///FORM VALIDATION
  // bool tagsAreValid() {
  //   if (stream.tags == null || stream.tags!.isEmpty) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

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
    if (img == null && stream.imageURL == null) {
      _snackbarService!.showSnackbar(
        title: 'Stream Image Error',
        message: 'Your stream must have an image',
        duration: Duration(seconds: 3),
      );
    } else if (!titleIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Stream Title Required',
        message: 'The title for your stream cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!descIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Stream Description Required',
        message: 'The description for your stream cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!audienceLocationIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Stream Audiences Location Required',
        message: 'The target location for your stream cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!startDateIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Stream Start Date Required',
        message: 'The start date & time for your stream cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!endDateIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Stream End Date Error',
        message: "End date & time must be set after the start date & time",
        duration: Duration(seconds: 5),
      );
    } else if (stream.fbUsername != null && stream.fbUsername!.isNotEmpty && !fbUsernameIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Facebook Username Error',
        message: "Facebook username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (stream.instaUsername != null && stream.instaUsername!.isNotEmpty && !instaUsernameIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Instagram Username Error',
        message: "Instagram username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (stream.twitterUsername != null && stream.twitterUsername!.isNotEmpty && !twitterUsernameIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Twitter Username Error',
        message: "Twitter username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (stream.twitchUsername != null && stream.twitchUsername!.isNotEmpty && !twitchUsernameIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Twitch Username Error',
        message: "Twitch username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (stream.website != null && stream.website!.isNotEmpty && !websiteIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Website URL Error',
        message: "Website URL must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (stream.youtube != null && stream.youtube!.isNotEmpty && !websiteIsValid()) {
      _snackbarService!.showSnackbar(
        title: 'Youtube URL Error',
        message: "Youtube URL must be valid",
        duration: Duration(seconds: 3),
      );
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<bool> submitStream() async {
    bool success = true;

    //upload img if exists
    if (img != null) {
      String? imageURL = await _firestoreStorageService!.uploadImage(img: img!, storageBucket: 'images', folderName: 'streams', fileName: stream.id!);
      if (imageURL == null) {
        _snackbarService!.showSnackbar(
          title: 'Stream Upload Error',
          message: 'There was an issue uploading your stream. Please try again.',
          duration: Duration(seconds: 3),
        );
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
      _snackbarService!.showSnackbar(
        title: 'Stream Upload Error',
        message: 'There was an issue uploading your stream. Please try again.',
        duration: Duration(seconds: 3),
      );
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
        _snackbarService!.showSnackbar(
          title: 'Insufficient Funds',
          message: 'You do no have enough WBLN to schedule this stream',
          duration: Duration(seconds: 3),
        );
      } else if (res == "confirmed") {
        submitForm();
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
