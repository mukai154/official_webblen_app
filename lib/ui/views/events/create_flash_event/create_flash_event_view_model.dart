import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/time.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/file_uploader/reactive_file_uploader_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreateFlashEventViewModel extends ReactiveViewModel {
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  EventDataService _eventDataService = locator<EventDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ReactiveFileUploaderService _reactiveFileUploaderService = locator<ReactiveFileUploaderService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();

  ///EVENT DETAILS CONTROLLERS
  TextEditingController eventStartDateTextController = TextEditingController();
  TextEditingController eventEndDateTextController = TextEditingController();

  ///HELPERS
  bool initialized = false;
  bool textFieldEnabled = true;

  bool get isLoggedIn => _reactiveUserService.userLoggedIn;
  WebblenUser get user => _reactiveUserService.user;

  ///FILE DATA
  File? fileToUpload;

  ///EVENT DATA
  String? id;
  WebblenEvent event = WebblenEvent();

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
  double? newEventTaxRate;
  double? promo;

  ///REACTIVE SERVICES
  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService, _reactiveFileUploaderService];

  ///INITIALIZE
  initialize({String? eventID, String? promoVal}) async {
    setBusy(true);

    //get promo
    if (promoVal != null) {
      promo = double.parse(promoVal);
    }
    //generate new event
    event = WebblenEvent().generateNewWebblenFlashEvent(authorID: user.id!, suggestedUIDs: user.followers == null ? [] : user.followers!);

    //set timezone
    event.timezone = getCurrentTimezone();
    notifyListeners();

    //get webblen rates
    newEventTaxRate = await _platformDataService.getNewEventTaxRate();
    if (newEventTaxRate == null) {
      newEventTaxRate = 0.05;
    }

    //complete initialization
    initialized = true;

    notifyListeners();
    setBusy(false);
  }

  ///EVENT IMAGE
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
              title: "Photos Permission Required",
              description: "Please open your app settings and enable access to your photos",
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

  ///EVENT INFO
  updateTitle(String val) {
    event.title = val;
    notifyListeners();
  }

  ///EVENT LOCATION
  Future<bool> updateLocation(Map<String, dynamic> details) async {
    bool success = true;
    setBusy(true);
    if (details.isEmpty) {
      return false;
    }

    //set nearest zipcodes
    event.nearbyZipcodes = await _locationService.findNearestZipcodes(details['areaCode']);
    if (event.nearbyZipcodes == null) {
      setBusy(false);
      return false;
    }

    //set lat
    event.lat = details['lat'];

    //set lon
    event.lon = details['lon'];

    //set address
    event.streetAddress = details['streetAddress'];

    //set city
    event.city = details['cityName'];

    //get province
    event.province = details['province'];

    notifyListeners();
    setBusy(false);
    return success;
  }

  updateVenueName(String val) {
    event.venueName = val;
    notifyListeners();
  }

  updateVenueSize(String val) {
    event.venueSize = val;
    notifyListeners();
  }

  ///EVENT DATA & TIME
  selectDate({required bool selectingStartDate}) async {
    //set selectable dates
    Map<String, dynamic> customData = selectingStartDate
        ? {'minSelectedDate': DateTime.now().subtract(Duration(days: 1)), 'selectedDate': selectedStartDate}
        : {'minSelectedDate': selectedStartDate, 'selectedDate': selectedEndDate ?? selectedStartDate};
    var sheetResponse = await _bottomSheetService.showCustomSheet(
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
        event.startDate = formattedDate;
        eventStartDateTextController.text = formattedDate;
      }
      //set end date
      if (!selectingStartDate || selectedEndDate == null) {
        selectedEndDate = selectedDate;
        event.endDate = formattedDate;
        eventEndDateTextController.text = formattedDate;
      }
      notifyListeners();
    }
  }

  onSelectedTimeFromDropdown({required bool selectedStartTime, required String time}) {
    if (selectedStartTime) {
      event.startTime = time;
    } else {
      event.endTime = time;
    }
    notifyListeners();
  }

  onSelectedTimezoneFromDropdown(String val) {
    event.timezone = val;
    notifyListeners();
  }

  ///FORM VALIDATION
  bool titleIsValid() {
    return isValidString(event.title);
  }

  bool addressIsValid() {
    return isValidString(event.streetAddress);
  }

  bool venueNameIsValid() {
    return isValidString(event.venueName);
  }

  bool startDateIsValid() {
    bool isValid = isValidString(event.startDate);
    if (isValid) {
      String eventStartDateAndTime = event.startDate! + " " + event.startTime!;
      event.startDateTimeInMilliseconds = dateTimeFormatter.parse(eventStartDateAndTime).millisecondsSinceEpoch;
      notifyListeners();
    }
    return isValid;
  }

  bool endDateIsValid() {
    bool isValid = isValidString(event.endDate);
    if (isValid) {
      String eventEndDateAndTime = event.endDate! + " " + event.endTime!;
      event.endDateTimeInMilliseconds = dateTimeFormatter.parse(eventEndDateAndTime).millisecondsSinceEpoch;
      notifyListeners();
      if (event.endDateTimeInMilliseconds! < event.startDateTimeInMilliseconds!) {
        isValid = false;
      }
    }
    return isValid;
  }

  bool formIsValid() {
    bool isValid = false;
    if (fileToUpload == null && event.imageURL == null) {
      _customDialogService.showErrorDialog(
        description: 'Your event must have an image',
      );
    } else if (!titleIsValid()) {
      _customDialogService.showErrorDialog(
        description: 'The title for your event cannot be empty',
      );
    } else if (!addressIsValid()) {
      _customDialogService.showErrorDialog(
        description: 'The location for your event cannot be empty',
      );
    } else if (!venueNameIsValid()) {
      _customDialogService.showErrorDialog(
        description: 'The venue name for your event cannot be empty',
      );
    } else if (!startDateIsValid()) {
      _customDialogService.showErrorDialog(
        description: 'The start date & time for your event cannot be empty',
      );
    } else if (!endDateIsValid()) {
      _customDialogService.showErrorDialog(
        description: "End date & time must be set after the start date & time",
      );
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<bool> uploadData() async {
    bool success = true;

    //upload img if exists
    if (fileToUpload != null) {
      String? imageURL = await _firestoreStorageService.uploadImage(img: fileToUpload!, storageBucket: 'images', folderName: 'streams', fileName: event.id!);
      if (imageURL == null) {
        _customDialogService.showErrorDialog(
          description: 'There was an issue uploading your stream. Please try again.',
        );
        return false;
      }
      event.imageURL = imageURL;
    }

    //upload tickets if they exist

    //set suggested uids for event
    event.suggestedUIDs = event.suggestedUIDs == null ? user.followers : event.suggestedUIDs;

    //upload event data
    var uploadResult;
    uploadResult = await _eventDataService.createEvent(event: event);

    if (uploadResult is String) {
      _customDialogService.showErrorDialog(
        description: 'There was an issue uploading your event. Please try again.',
      );
      return false;
    }

    //cache username data
    if (isValidString(event.fbUsername)) {
      await _userDataService.updateFbUsername(id: event.authorID!, val: event.fbUsername!);
    }
    if (isValidString(event.instaUsername)) {
      await _userDataService.updateInstaUsername(id: event.authorID!, val: event.instaUsername!);
    }
    if (isValidString(event.twitterUsername)) {
      await _userDataService.updateTwitterUsername(id: event.authorID!, val: event.twitterUsername!);
    }

    return success;
  }

  submitForm() async {
    setBusy(true);
    //submit new event
    bool uploaded = await uploadData();
    if (uploaded) {
      //show bottom sheet
      displayUploadSuccessBottomSheet();
    }
    setBusy(false);
  }

  showNewContentConfirmationBottomSheet({BuildContext? context}) async {
    setBusy(true);
    await Future.delayed(Duration(seconds: 1));

    //exit function if form is invalid
    if (!formIsValid()) {
      setBusy(false);
      return;
    }

    //display event confirmation
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      title: "Create Flash Event?",
      description: "A check-in will be created for the next hour",
      mainButtonTitle: "Create Flash Event",
      secondaryButtonTitle: "Cancel",
      customData: {'fee': newEventTaxRate, 'promo': promo},
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
        _customDialogService.showErrorDialog(
          description: 'You do no have enough WBLN to create a flash event',
        );
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
    _userDataService.withdrawWebblen(uid: user.id, amount: newEventTaxRate!);

    //display success
    var sheetResponse = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.addContentSuccessful,
        takesInput: false,
        customData: event,
        barrierDismissible: false,
        title: "A check-in for this event is now available 🎉");

    if (sheetResponse == null || sheetResponse.responseData == "done") {
      _reactiveFileUploaderService.clearUploaderData();
      _customNavigationService.navigateToBase();
    }
  }

  ///NAVIGATION
  navigateBack() async {
    bool confirmed = false;
    confirmed = await _customBottomSheetService.showCancelCreatingContentBottomSheet(content: event);
    if (confirmed) {
      _customNavigationService.navigateToBase();
    }
  }
}
