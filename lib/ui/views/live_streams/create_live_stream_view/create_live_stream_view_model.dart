import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/time.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/extensions/custom_date_time_extensions.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreateLiveStreamViewModel extends BaseViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  PlatformDataService? _platformDataService = locator<PlatformDataService>();
  UserDataService? _userDataService = locator<UserDataService>();
  LocationService? _locationService = locator<LocationService>();
  FirestoreStorageService? _firestoreStorageService = locator<FirestoreStorageService>();
  LiveStreamDataService? _liveStreamDataService = locator<LiveStreamDataService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  TicketDistroDataService? _ticketDistroDataService = locator<TicketDistroDataService>();
  StripeConnectAccountService? _stripeConnectAccountService = locator<StripeConnectAccountService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();
  late SharedPreferences _sharedPreferences;

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
  TextEditingController fbStreamURLTextController = TextEditingController();
  TextEditingController twitchStreamURLTextController = TextEditingController();
  TextEditingController youtubeStreamURLTextController = TextEditingController();

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

  ///USER DATA
  bool? hasEarningsAccount;

  ///STREAM DATA
  bool isEditing = false;
  int? ticketToEditIndex;
  int? feeToEditIndex;
  int? discountToEditIndex;
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

  ///TICKETING
  WebblenTicketDistro? ticketDistro = WebblenTicketDistro(tickets: [], fees: [], discountCodes: []);
  GlobalKey ticketFormKey = GlobalKey<FormState>();
  GlobalKey feeFormKey = GlobalKey<FormState>();
  GlobalKey discountFormKey = GlobalKey<FormState>();

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
  double? newStreamTaxRate;
  double? promo;

  ///INITIALIZE
  initialize(String id, double promo) async {
    setBusy(true);

    _sharedPreferences = await SharedPreferences.getInstance();

    //generate new event
    stream = WebblenLiveStream().generateNewWebblenLiveStream(hostID: user.id!, suggestedUIDs: []);

    //check if user has earnings account
    hasEarningsAccount = await _stripeConnectAccountService!.isStripeConnectAccountSetup(user.id);

    //set timezone
    stream.timezone = getCurrentTimezone();
    stream.startTime = timeFormatter.format(DateTime.now().add(Duration(hours: 1)).roundDown(delta: Duration(minutes: 30)));
    stream.endTime = timeFormatter.format(DateTime.now().add(Duration(hours: 2)).roundDown(delta: Duration(minutes: 30)));
    notifyListeners();

    //set previously used social accounts
    fbUsernameTextController.text = _sharedPreferences.getString('fbUsername') ?? "";
    instaUsernameTextController.text = _sharedPreferences.getString('instaUsername') ?? "";
    twitterUsernameTextController.text = _sharedPreferences.getString('twitterUsername') ?? "";
    websiteTextController.text = _sharedPreferences.getString('website') ?? "";
    twitchTextController.text = _sharedPreferences.getString('twitchUsername') ?? "";
    youtubeTextController.text = _sharedPreferences.getString('youtube') ?? "";
    fbStreamKeyTextController.text = _sharedPreferences.getString('fbStreamKey') ?? "";
    twitchStreamKeyTextController.text = _sharedPreferences.getString('twitchStreamKey') ?? "";
    youtubeStreamKeyTextController.text = _sharedPreferences.getString('youtubeStreamKey') ?? "";
    fbStreamURLTextController.text = _sharedPreferences.getString('fbStreamURL') ?? "";
    twitchStreamURLTextController.text = _sharedPreferences.getString('twitchStreamURL') ?? "";
    youtubeStreamURLTextController.text = _sharedPreferences.getString('youtubeStreamURL') ?? "";

    if (id != "new") {
      stream = await _liveStreamDataService!.getStreamByID(id);
      if (stream.isValid()) {
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
        fbStreamURLTextController.text = stream.fbStreamURL == null ? "" : stream.fbStreamURL!;
        twitchStreamURLTextController.text = stream.twitchStreamURL == null ? "" : stream.twitchStreamURL!;
        youtubeStreamURLTextController.text = stream.youtubeStreamURL == null ? "" : stream.youtubeStreamURL!;
        selectedStartDate = dateFormatter.parse(stream.startDate!);
        selectedEndDate = dateFormatter.parse(stream.endDate!);
        isEditing = true;
        //check if editing with ticket distro
        if (stream.hasTickets!) {
          ticketDistro = await _ticketDistroDataService!.getTicketDistroByID(stream.id);
        }
      }
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
        }
      } else if (source == "gallery") {
        bool hasPhotosPermission = await _permissionHandlerService.hasPhotosPermission();
        if (hasPhotosPermission) {
          img = await WebblenImagePicker().retrieveImageFromLibrary(ratioX: 1, ratioY: 1);
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

    if (details == null || details.isEmpty) {
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
      customData: customData,
      barrierDismissible: true,
      variant: BottomSheetType.calendar,
    );
    if (sheetResponse != null) {
      //format selected date
      DateTime selectedDate = sheetResponse.responseData;
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

  ///STREAM TICKETING, FEES, AND DISCOUNTS
  //tickets
  toggleTicketForm({required int? ticketIndex}) {
    if (ticketIndex == null) {
      if (showTicketForm) {
        showTicketForm = false;
      } else {
        showTicketForm = true;
      }
    } else {
      showTicketForm = true;
      Map<String, dynamic> ticket = ticketDistro!.tickets![ticketIndex];
      ticketNameTextController.text = ticket['ticketName'];
      ticketQuantityTextController.text = ticket['ticketQuantity'];
      ticketPriceTextController.text = ticket['ticketPrice'];
      ticketToEditIndex = ticketIndex;
    }
    notifyListeners();
  }

  addTicket() {
    if (ticketNameTextController.text.trim().isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Ticket Name Required',
        message: 'Please add a name for this ticket',
        duration: Duration(seconds: 3),
      );
      return;
    } else if (ticketQuantityTextController.text.trim().isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Ticket Quantity Required',
        message: 'Please set a quantity for this ticket',
        duration: Duration(seconds: 3),
      );
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
      ticketDistro!.tickets![ticketToEditIndex!] = eventTicket;
      ticketToEditIndex = null;
    } else {
      ticketDistro!.tickets!.add(eventTicket);
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
      ticketDistro!.tickets!.removeAt(ticketToEditIndex!);
      ticketToEditIndex = null;
    }
    notifyListeners();
  }

  //fees
  toggleFeeForm({required int? feeIndex}) {
    if (feeIndex == null) {
      if (showFeeForm) {
        showFeeForm = false;
      } else {
        showFeeForm = true;
      }
    } else {
      showFeeForm = true;
      Map<String, dynamic> fee = ticketDistro!.fees![feeIndex];
      feeNameTextController.text = fee['feeName'];
      feePriceTextController.text = fee['feePrice'];
      feeToEditIndex = feeIndex;
    }
    notifyListeners();
  }

  addFee() {
    if (feeNameTextController.text.trim().isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Fee Name Required',
        message: 'Please add a name for this fee',
        duration: Duration(seconds: 3),
      );
      return;
    }

    Map<String, dynamic> eventFee = {
      "feeName": feeNameTextController.text.trim(),
      "feePrice": feePriceTextController.text.trim(),
    };

    feeNameTextController.clear();
    feePriceTextController.text = "\$0.00";

    if (feeToEditIndex != null) {
      ticketDistro!.fees![feeToEditIndex!] = eventFee;
      feeToEditIndex = null;
    } else {
      ticketDistro!.fees!.add(eventFee);
    }
    showFeeForm = false;
    notifyListeners();
  }

  deleteFee() {
    feeNameTextController.clear();
    feePriceTextController.text = "\$0.00";
    showFeeForm = false;
    if (feeToEditIndex != null) {
      ticketDistro!.fees!.removeAt(feeToEditIndex!);
      feeToEditIndex = null;
    }
    notifyListeners();
  }

  //discounts
  toggleDiscountsForm({required int? discountIndex}) {
    if (discountIndex == null) {
      if (showDiscountCodeForm) {
        showDiscountCodeForm = false;
      } else {
        showDiscountCodeForm = true;
      }
    } else {
      showDiscountCodeForm = true;
      Map<String, dynamic> discount = ticketDistro!.discountCodes![discountIndex];
      discountNameTextController.text = discount['discountName'];
      discountLimitTextController.text = discount['discountLimit'];
      discountValueTextController.text = discount['discountValue'];
      discountToEditIndex = discountIndex;
    }
    notifyListeners();
  }

  addDiscount() {
    if (discountNameTextController.text.trim().isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Discount Code Required',
        message: 'Please add a code for this discount',
        duration: Duration(seconds: 3),
      );
      return;
    } else if (discountLimitTextController.text.trim().isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Discount Limit Required',
        message: 'Please set a limit for the number of times this discount can be used',
        duration: Duration(seconds: 5),
      );
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
      ticketDistro!.discountCodes![discountToEditIndex!] = eventDiscount;
      discountToEditIndex = null;
    } else {
      ticketDistro!.discountCodes!.add(eventDiscount);
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
      ticketDistro!.discountCodes!.removeAt(discountToEditIndex!);
      discountToEditIndex = null;
    }
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

  setYoutubeStreamURL(String val) {
    stream.youtubeStreamURL = val.trim();
    notifyListeners();
  }

  setYoutubeStreamKey(String val) {
    stream.youtubeStreamKey = val.trim();
    notifyListeners();
  }

  setTwitchStreamURL(String val) {
    stream.twitchStreamURL = val.trim();
    notifyListeners();
  }

  setTwitchStreamKey(String val) {
    stream.twitchStreamKey = val.trim();
    notifyListeners();
  }

  setFBStreamURL(String val) {
    stream.fbStreamURL = val.trim();
    notifyListeners();
  }

  setFBStreamKey(String val) {
    stream.fbStreamKey = val.trim();
    notifyListeners();
  }

  ///FORM VALIDATION
  bool tagsAreValid() {
    if (stream.tags == null || stream.tags!.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

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
    } else if (!tagsAreValid()) {
      _snackbarService!.showSnackbar(
        title: 'Tag Error',
        message: 'Your stream must contain at least 1 tag',
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
      uploadResult = await _liveStreamDataService!.updateStream(stream: stream);
    } else {
      uploadResult = await _liveStreamDataService!.createStream(stream: stream);
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
    await _sharedPreferences.setString('fbUsername', stream.fbUsername == null ? "" : stream.fbUsername!);
    await _sharedPreferences.setString('instaUsername', stream.instaUsername == null ? "" : stream.instaUsername!);
    await _sharedPreferences.setString('twitterUsername', stream.twitterUsername == null ? "" : stream.twitterUsername!);
    await _sharedPreferences.setString('twitchUsername', stream.twitchUsername == null ? "" : stream.twitchUsername!);
    await _sharedPreferences.setString('website', stream.website == null ? "" : stream.website!);
    await _sharedPreferences.setString('youtube', stream.youtube == null ? "" : stream.youtube!);
    await _sharedPreferences.setString('fbStreamKey', stream.fbStreamKey == null ? "" : stream.fbStreamKey!);
    await _sharedPreferences.setString('twitchStreamKey', stream.twitchStreamKey == null ? "" : stream.twitchStreamKey!);
    await _sharedPreferences.setString('youtubeStreamKey', stream.youtubeStreamKey == null ? "" : stream.youtubeStreamKey!);
    await _sharedPreferences.setString('fbStreamURL', stream.fbStreamURL == null ? "" : stream.fbStreamURL!);
    await _sharedPreferences.setString('twitchStreamURL', stream.twitchStreamURL == null ? "" : stream.twitchStreamURL!);
    await _sharedPreferences.setString('youtubeStreamURL', stream.youtubeStreamURL == null ? "" : stream.youtubeStreamURL!);
    return success;
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
      _userDataService!.depositWebblen(uid: user.id, amount: promo!);
    }
    _userDataService!.withdrawWebblen(uid: user.id, amount: newStreamTaxRate!);

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
