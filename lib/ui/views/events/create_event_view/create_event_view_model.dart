import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/time.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/extensions/custom_date_time_extensions.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/file_uploader/reactive_file_uploader_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreateEventViewModel extends ReactiveViewModel {
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  EventDataService _eventDataService = locator<EventDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ReactiveFileUploaderService _reactiveFileUploaderService = locator<ReactiveFileUploaderService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();

  ///EVENT DETAILS CONTROLLERS
  TextEditingController tagTextController = TextEditingController();
  TextEditingController eventStartDateTextController = TextEditingController();
  TextEditingController eventEndDateTextController = TextEditingController();

  ///TICKET DETAILS CONTROLLERS
  TextEditingController ticketNameTextController = TextEditingController();
  TextEditingController ticketQuantityTextController = TextEditingController();
  MoneyMaskedTextController ticketPriceTextController = MoneyMaskedTextController(
    leftSymbol: "\$",
    precision: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
  );

  ///FEE DETAILS CONTROLLERS
  TextEditingController feeNameTextController = TextEditingController();
  MoneyMaskedTextController feePriceTextController = MoneyMaskedTextController(
    leftSymbol: "\$",
    precision: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
  );

  ///DISCOUNT DETAILS CONTROLLERS
  TextEditingController discountNameTextController = TextEditingController();
  TextEditingController discountLimitTextController = TextEditingController();
  MoneyMaskedTextController discountValueTextController = MoneyMaskedTextController(
    leftSymbol: "\$",
    precision: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
  );

  ///HELPERS
  bool initialized = false;
  bool textFieldEnabled = true;
  bool loadedPreviousTitle = false;
  bool loadedPreviousDescription = false;
  bool loadedPreviousVenueName = false;
  bool loadedPreviousFBUsername = false;
  bool loadedPreviousInstaUsername = false;
  bool loadedPreviousTwitterUsername = false;
  bool loadedPreviousWebsite = false;

  ///USER DATA
  bool? hasEarningsAccount;
  bool dismissedEarningsAccountNotice = false;
  bool get isLoggedIn => _reactiveUserService.userLoggedIn;
  WebblenUser get user => _reactiveUserService.user;

  ///FILE DATA
  File? fileToUpload;

  ///EVENT DATA
  String? id;
  bool isEditing = false;
  bool isDuplicate = false;

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

  ///TICKETING
  WebblenTicketDistro ticketDistro = WebblenTicketDistro(tickets: [], fees: [], discountCodes: []);
  GlobalKey ticketFormKey = GlobalKey<FormState>();
  GlobalKey feeFormKey = GlobalKey<FormState>();
  GlobalKey discountFormKey = GlobalKey<FormState>();
  int? ticketToEditIndex;
  int? feeToEditIndex;
  int? discountToEditIndex;

  bool showTicketForm = false;
  bool showFeeForm = false;
  bool showDiscountCodeForm = false;

  String? ticketName;
  String? ticketPrice;
  String? ticketQuantity;
  String? feeName;
  String? feeAmount;
  String? discountCodeName;
  String? discountCodeQuantity;
  String? discountCodePercentage;

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
    ticketDistro.authorID = user.id;
    event = WebblenEvent().generateNewWebblenEvent(authorID: user.id!, suggestedUIDs: user.followers == null ? [] : user.followers!);

    //check if user has earnings account
    hasEarningsAccount = await _stripeConnectAccountService.isStripeConnectAccountSetup(user.id!);

    //set timezone
    event.timezone = getCurrentTimezone();
    event.startTime = timeFormatter.format(DateTime.now().add(Duration(hours: 1)).roundDown(delta: Duration(minutes: 30)));
    event.endTime = timeFormatter.format(DateTime.now().add(Duration(hours: 2)).roundDown(delta: Duration(minutes: 30)));
    notifyListeners();

    //check for promos & if editing/duplicating existing event
    if (eventID!.contains("duplicate_")) {
      String id = eventID.replaceAll("duplicate_", "");
      event = await _eventDataService.getEventByID(id);
      if (event.isValid()) {
        event.id = getRandomString(32);
        if (event.hasTickets!) {
          ticketDistro = await _ticketDistroDataService.getTicketDistroByID(id);
          ticketDistro.eventID = event.id;
        }
        event.attendees = {};
        event.savedBy = [];
        isDuplicate = true;
      }
    } else if (eventID != "new") {
      event = await _eventDataService.getEventByID(eventID);
      if (event.isValid()) {
        eventStartDateTextController.text = event.startDate!;
        eventEndDateTextController.text = event.endDate!;
        selectedStartDate = dateFormatter.parse(event.startDate!);
        selectedEndDate = dateFormatter.parse(event.endDate!);
        isEditing = true;
        if (event.hasTickets!) {
          ticketDistro = await _ticketDistroDataService.getTicketDistroByID(event.id);
        }
      }
    } else {
      event.fbUsername = await _userDataService.getCurrentFbUsername(user.id!);
      event.instaUsername = await _userDataService.getCurrentInstaUsername(user.id!);
      event.twitterUsername = await _userDataService.getCurrentTwitterUsername(user.id!);
      event.website = await _userDataService.getCurrentUserWebsite(user.id!);
    }

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

  dismissEarningsAccountNotice() {
    dismissedEarningsAccountNotice = true;
    notifyListeners();
  }

  ///LOAD PREVIOUS DATA
  String loadPreviousTitle() {
    String val = "";
    if (!loadedPreviousTitle) {
      val = event.title ?? "";
    }
    loadedPreviousTitle = true;
    notifyListeners();
    return val;
  }

  String loadPreviousDesc() {
    String val = "";
    if (!loadedPreviousDescription) {
      val = event.description ?? "";
    }
    loadedPreviousDescription = true;
    notifyListeners();
    return val;
  }

  String loadPreviousVenueName() {
    String val = "";
    if (!loadedPreviousVenueName) {
      val = event.venueName ?? "";
    }
    loadedPreviousVenueName = true;
    notifyListeners();
    return val;
  }

  String loadPreviousFBUsername() {
    String val = "";
    if (!loadedPreviousFBUsername) {
      val = event.fbUsername ?? "";
    }
    loadedPreviousFBUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousInstaUsername() {
    String val = "";
    if (!loadedPreviousInstaUsername) {
      val = event.instaUsername ?? "";
    }
    loadedPreviousInstaUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousTwitterUsername() {
    String val = "";
    if (!loadedPreviousTwitterUsername) {
      val = event.twitterUsername ?? "";
    }
    loadedPreviousTwitterUsername = true;
    notifyListeners();
    return val;
  }

  String loadPreviousWebsite() {
    String val = "";
    if (!loadedPreviousWebsite) {
      val = event.website ?? "";
    }
    loadedPreviousWebsite = true;
    notifyListeners();
    return val;
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

  ///EVENT TAGS
  addTag(String tag) {
    List tags = event.tags == null ? [] : event.tags!.toList(growable: true);

    //check if tag already listed
    if (!tags.contains(tag)) {
      //check if tag limit has been reached
      if (tags.length == 3) {
        _customDialogService.showErrorDialog(description: "You can only add up to 3 tags for your event");
      } else {
        //add tag
        tags.add(tag);
        event.tags = tags;
        notifyListeners();
      }
    }
    tagTextController.clear();
  }

  removeTagAtIndex(int index) {
    List tags = event.tags == null ? [] : event.tags!.toList(growable: true);
    tags.removeAt(index);
    event.tags = tags;
    notifyListeners();
  }

  ///EVENT INFO
  updateTitle(String val) {
    event.title = val;
    notifyListeners();
  }

  updateDescription(String val) {
    event.description = val;
    notifyListeners();
  }

  onSelectedPrivacyFromDropdown(String val) {
    event.privacy = val;
    notifyListeners();
  }

  ///EVENT LOCATION
  Future<bool> updateLocation(Map<String, dynamic> details) async {
    bool success = true;

    if (details.isEmpty) {
      return false;
    }

    //set nearest zipcodes
    event.nearbyZipcodes = await _locationService.findNearestZipcodes(details['areaCode']);
    if (event.nearbyZipcodes == null) {
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

  ///EVENT TICKETING, FEES, AND DISCOUNTS
  //tickets
  toggleTicketForm({int? ticketIndex}) {
    if (ticketIndex == null) {
      if (showTicketForm) {
        showTicketForm = false;
      } else {
        showTicketForm = true;
      }
    } else {
      showTicketForm = true;
      Map<String, dynamic> ticket = ticketDistro.tickets![ticketIndex];
      ticketNameTextController.text = ticket['ticketName'];
      ticketQuantityTextController.text = ticket['ticketQuantity'];
      ticketPriceTextController.text = ticket['ticketPrice'];
      ticketToEditIndex = ticketIndex;
    }
    notifyListeners();
  }

  addTicket() {
    if (ticketNameTextController.text.trim().isEmpty) {
      _customDialogService.showErrorDialog(description: "Ticket Name Required");
      return;
    } else if (ticketQuantityTextController.text.trim().isEmpty) {
      _customDialogService.showErrorDialog(description: "Ticket Quantity Required");
      return;
    }

    Map<String, dynamic> eventTicket = {
      "ticketName": ticketNameTextController.text.trim(),
      "ticketQuantity": ticketQuantityTextController.text.trim(),
      "ticketPrice": ticketPriceTextController.text.trim(),
    };

    ticketNameTextController.clear();
    ticketQuantityTextController.clear();
    ticketPriceTextController.text = "\$0.00";

    if (ticketToEditIndex != null) {
      ticketDistro.tickets![ticketToEditIndex!] = eventTicket;
      ticketToEditIndex = null;
    } else {
      ticketDistro.tickets!.add(eventTicket);
    }
    showTicketForm = false;
    notifyListeners();
  }

  deleteTicket() {
    ticketNameTextController.clear();
    ticketQuantityTextController.clear();
    ticketPriceTextController.text = "\$0.00";
    showTicketForm = false;
    if (ticketToEditIndex != null) {
      ticketDistro.tickets!.removeAt(ticketToEditIndex!);
      ticketToEditIndex = null;
    }
    notifyListeners();
  }

  //fees
  toggleFeeForm({int? feeIndex}) {
    if (feeIndex == null) {
      if (showFeeForm) {
        showFeeForm = false;
      } else {
        showFeeForm = true;
      }
    } else {
      showFeeForm = true;
      Map<String, dynamic> fee = ticketDistro.fees![feeIndex];
      feeNameTextController.text = fee['feeName'];
      feePriceTextController.text = fee['feePrice'];
      feeToEditIndex = feeIndex;
    }
    notifyListeners();
  }

  addFee() {
    if (feeNameTextController.text.trim().isEmpty) {
      _customDialogService.showErrorDialog(description: "Fee Name Required");
      return;
    }

    Map<String, dynamic> eventFee = {
      "feeName": feeNameTextController.text.trim(),
      "feePrice": feePriceTextController.text.trim(),
    };

    feeNameTextController.clear();
    feePriceTextController.text = "\$0.00";

    if (feeToEditIndex != null) {
      ticketDistro.fees![feeToEditIndex!] = eventFee;
      feeToEditIndex = null;
    } else {
      ticketDistro.fees!.add(eventFee);
    }
    showFeeForm = false;
    notifyListeners();
  }

  deleteFee() {
    feeNameTextController.clear();
    feePriceTextController.text = "\$0.00";
    showFeeForm = false;
    if (feeToEditIndex != null) {
      ticketDistro.fees!.removeAt(feeToEditIndex!);
      feeToEditIndex = null;
    }
    notifyListeners();
  }

  //discounts
  toggleDiscountsForm({int? discountIndex}) {
    if (discountIndex == null) {
      if (showDiscountCodeForm) {
        showDiscountCodeForm = false;
      } else {
        showDiscountCodeForm = true;
      }
    } else {
      showDiscountCodeForm = true;
      Map<String, dynamic> discount = ticketDistro.discountCodes![discountIndex];
      discountNameTextController.text = discount['discountName'];
      discountLimitTextController.text = discount['discountLimit'];
      discountValueTextController.text = discount['discountValue'];
      discountToEditIndex = discountIndex;
    }
    notifyListeners();
  }

  addDiscount() {
    if (discountNameTextController.text.trim().isEmpty) {
      _customDialogService.showErrorDialog(description: "Discount Code Required");
      return;
    } else if (discountLimitTextController.text.trim().isEmpty) {
      _customDialogService.showErrorDialog(description: "Discount Limit Required");
      return;
    }

    Map<String, dynamic> eventDiscount = {
      "discountName": discountNameTextController.text.trim(),
      "discountLimit": discountLimitTextController.text.trim(),
      "discountValue": discountValueTextController.text.trim(),
    };

    discountNameTextController.clear();
    discountLimitTextController.clear();
    discountValueTextController.text = "\$0.00";

    if (discountToEditIndex != null) {
      ticketDistro.discountCodes![discountToEditIndex!] = eventDiscount;
      discountToEditIndex = null;
    } else {
      ticketDistro.discountCodes!.add(eventDiscount);
    }
    showDiscountCodeForm = false;
    notifyListeners();
  }

  deleteDiscount() {
    discountNameTextController.clear();
    discountLimitTextController.clear();
    discountValueTextController.text = "\$0.00";
    showDiscountCodeForm = false;
    if (discountToEditIndex != null) {
      ticketDistro.discountCodes!.removeAt(discountToEditIndex!);
      discountToEditIndex = null;
    }
    notifyListeners();
  }

  ///ADDITIONAL EVENT INFO
  updateVideoStreamStatus(bool val) {
    event.hasStream = val;
    notifyListeners();
  }

  updateSponsorshipStatus(bool val) {
    event.openToSponsors = val;
    notifyListeners();
  }

  updateFBUsername(String val) {
    event.fbUsername = val.trim();
    notifyListeners();
  }

  updateInstaUsername(String val) {
    event.instaUsername = val.trim();
    notifyListeners();
  }

  updateTwitterUsername(String val) {
    event.twitterUsername = val.trim();
    notifyListeners();
  }

  updateWebsite(String val) {
    event.website = val.trim();
    notifyListeners();
  }

  ///FORM VALIDATION
  bool tagsAreValid() {
    if (event.tags == null || event.tags!.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool titleIsValid() {
    return isValidString(event.title);
  }

  bool descIsValid() {
    return isValidString(event.description);
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

  bool fbUsernameIsValid() {
    return isValidUsername(event.fbUsername!);
  }

  bool instaUsernameIsValid() {
    return isValidUsername(event.instaUsername!);
  }

  bool twitterUsernameIsValid() {
    return isValidUsername(event.twitterUsername!);
  }

  bool websiteIsValid() {
    return isValidUrl(event.website!);
  }

  bool formIsValid() {
    bool isValid = false;
    if (fileToUpload == null && event.imageURL == null) {
      _customDialogService.showErrorDialog(
        description: 'Your event must have an image',
      );
    } else if (!tagsAreValid()) {
      _customDialogService.showErrorDialog(
        description: 'Your event must contain at least 1 tag',
      );
    } else if (!titleIsValid()) {
      _customDialogService.showErrorDialog(
        description: 'The title for your event cannot be empty',
      );
    } else if (!descIsValid()) {
      _customDialogService.showErrorDialog(
        description: 'The description for your event cannot be empty',
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
    } else if (event.fbUsername != null && event.fbUsername!.isNotEmpty && !fbUsernameIsValid()) {
      _customDialogService.showErrorDialog(
        description: "Facebook username must be valid",
      );
    } else if (event.instaUsername != null && event.instaUsername!.isNotEmpty && !instaUsernameIsValid()) {
      _customDialogService.showErrorDialog(
        description: "Instagram username must be valid",
      );
    } else if (event.twitterUsername != null && event.twitterUsername!.isNotEmpty && !twitterUsernameIsValid()) {
      _customDialogService.showErrorDialog(
        description: "Twitter username must be valid",
      );
    } else if (event.website != null && event.website!.isNotEmpty && !websiteIsValid()) {
      _customDialogService.showErrorDialog(
        description: "Website URL must be valid",
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
    if (ticketDistro.tickets!.isNotEmpty) {
      event.hasTickets = true;
      if (isEditing) {
        bool editedExistingTickets = await _ticketDistroDataService.checkIfTicketDistroExists(event.id!);
        if (editedExistingTickets) {
          await _ticketDistroDataService.updateTicketDistro(eventID: event.id!, ticketDistro: ticketDistro);
        } else {
          await _ticketDistroDataService.createTicketDistro(eventID: event.id!, ticketDistro: ticketDistro);
        }
      } else {
        await _ticketDistroDataService.createTicketDistro(eventID: event.id!, ticketDistro: ticketDistro);
      }
    }

    //set suggested uids for event
    event.suggestedUIDs = event.suggestedUIDs == null ? user.followers : event.suggestedUIDs;

    //upload event data
    var uploadResult;
    if (isEditing) {
      uploadResult = await _eventDataService.updateEvent(event: event);
    } else {
      uploadResult = await _eventDataService.createEvent(event: event);
    }

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
    //FocusScope.of(context).unfocus();

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
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      title: "Schedule Event?",
      description: event.privacy == "Public" ? "Schedule this event for everyone to see" : "Your event is ready to be scheduled and shared",
      mainButtonTitle: "Schedule Event",
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
        _customDialogService.showErrorDialog(
          description: 'You do no have enough WBLN to schedule this event',
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
    _userDataService.withdrawWebblen(uid: user.id, amount: newEventTaxRate!);

    //display success
    var sheetResponse = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.addContentSuccessful,
        takesInput: false,
        customData: event,
        barrierDismissible: false,
        title: isEditing ? "Your event has been Updated" : "Your event has been Scheduled! 🎉");

    if (sheetResponse == null || sheetResponse.responseData == "done") {
      _reactiveFileUploaderService.clearUploaderData();
      _customNavigationService.navigateToBase();
    }
  }

  ///NAVIGATION
  navigateBack() async {
    bool confirmed = false;
    if (isEditing) {
      confirmed = await _customBottomSheetService.showCancelEditingContentBottomSheet();
    } else {
      confirmed = await _customBottomSheetService.showCancelCreatingContentBottomSheet(content: event);
    }
    if (confirmed) {
      _customNavigationService.navigateToBase();
    }
  }

  navigateBackToWalletPage() async {
    bool navigateToWallet = await _customDialogService.showNavigateToEarningsAccountDialog(isEditing: isEditing, contentType: "event");
    if (navigateToWallet) {
      _customNavigationService.navigateToWalletView();
    }
  }
}
