import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/time.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/extensions/custom_date_time_extensions.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreateEventViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  EventDataService _eventDataService = locator<EventDataService>();
  PostDataService _postDataService = locator<PostDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  WebblenBaseViewModel _webblenBaseViewModel = locator<WebblenBaseViewModel>();

  ///EVENT DETAILS CONTROLLERS
  TextEditingController tagTextController = TextEditingController();
  TextEditingController eventTitleTextController = TextEditingController();
  TextEditingController eventDescTextController = TextEditingController();
  TextEditingController eventVenueNameTextController = TextEditingController();
  TextEditingController eventStartDateTextController = TextEditingController();
  TextEditingController eventEndDateTextController = TextEditingController();
  TextEditingController instaUsernameTextController = TextEditingController();
  TextEditingController fbUsernameTextController = TextEditingController();
  TextEditingController twitterUsernameTextController = TextEditingController();
  TextEditingController websiteTextController = TextEditingController();

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
  bool textFieldEnabled = true;

  ///USER DATA
  bool hasEarningsAccount;

  ///EVENT DATA
  bool isEditing = false;
  int ticketToEditIndex;
  int feeToEditIndex;
  int discountToEditIndex;
  File img;

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
  DateTime selectedEndDate;

  ///TICKETING
  WebblenTicketDistro ticketDistro = WebblenTicketDistro(tickets: [], fees: [], discountCodes: []);
  GlobalKey ticketFormKey = GlobalKey<FormState>();
  GlobalKey feeFormKey = GlobalKey<FormState>();
  GlobalKey discountFormKey = GlobalKey<FormState>();

  bool showTicketForm = false;
  bool showFeeForm = false;
  bool showDiscountCodeForm = false;

  String ticketName;
  String ticketPrice;
  String ticketQuantity;
  String feeName;
  String feeAmount;
  String discountCodeName;
  String discountCodeQuantity;
  String discountCodePercentage;

  ///EVENT PRIVACY
  List<String> privacyOptions = ['public', 'private'];

  ///WEBBLEN CURRENCY
  double newEventTaxRate;

  ///INITIALIZE
  initialize({BuildContext context}) async {
    setBusy(true);

    //generate new event
    event = WebblenEvent().generateNewWebblenEvent(authorID: _webblenBaseViewModel.user.id);

    //check if user has earnings account
    hasEarningsAccount = await _stripeConnectAccountService.isStripeConnectAccountSetup(_webblenBaseViewModel.user.id);

    //set timezone
    event.timezone = getCurrentTimezone();
    event.startTime = timeFormatter.format(DateTime.now().add(Duration(hours: 1)).roundDown(delta: Duration(minutes: 30)));
    event.endTime = timeFormatter.format(DateTime.now().add(Duration(hours: 2)).roundDown(delta: Duration(minutes: 30)));
    notifyListeners();

    //check if editing existing event
    Map<String, dynamic> args = RouteData.of(context).arguments;
    if (args != null) {
      String eventID = args['id'] ?? "";
      if (eventID.isNotEmpty) {
        event = await _eventDataService.getEventByID(eventID);
        if (event != null) {
          eventTitleTextController.text = event.title;
          eventDescTextController.text = event.description;
          eventVenueNameTextController.text = event.venueName;
          eventStartDateTextController.text = event.startDate;
          eventEndDateTextController.text = event.endDate;
          fbUsernameTextController.text = event.fbUsername;
          instaUsernameTextController.text = event.instaUsername;
          twitterUsernameTextController.text = event.twitterUsername;
          websiteTextController.text = event.website;
          isEditing = true;

          //check if editing with ticket distro
          if (event.hasTickets) {
            ticketDistro = await _ticketDistroDataService.getTicketDistroByID(event.id);
          }
        }
      }
    }

    //get webblen rates
    newEventTaxRate = await _platformDataService.getNewEventTaxRate();
    if (newEventTaxRate == null) {
      newEventTaxRate = 0.05;
    }
    notifyListeners();
    setBusy(false);
  }

  ///EVENT IMAGE
  selectImage() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.imagePicker,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;

      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (res == "camera") {
        img = await WebblenImagePicker().retrieveImageFromCamera(ratioX: 1, ratioY: 1);
      } else if (res == "gallery") {
        img = await WebblenImagePicker().retrieveImageFromLibrary(ratioX: 1, ratioY: 1);
      }

      //wait a bit to re-enable text fields
      await Future.delayed(Duration(milliseconds: 500));
      textFieldEnabled = true;
      notifyListeners();
    }
  }

  ///EVENT TAGS
  addTag(String tag) {
    List tags = event.tags == null ? [] : event.tags.toList(growable: true);

    //check if tag already listed
    if (!tags.contains(tag)) {
      //check if tag limit has been reached
      if (tags.length == 3) {
        _snackbarService.showSnackbar(
          title: 'Tag Limit Reached',
          message: 'You can only add up to 3 tags for your post',
          duration: Duration(seconds: 5),
        );
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
    List tags = event.tags == null ? [] : event.tags.toList(growable: true);
    tags.removeAt(index);
    event.tags = tags;
    notifyListeners();
  }

  ///EVENT INFO
  setEventTitle(String val) {
    event.title = val;
    notifyListeners();
  }

  setEventDescription(String val) {
    event.description = val;
    notifyListeners();
  }

  onSelectedPrivacyFromDropdown(String val) {
    event.privacy = val;
    notifyListeners();
  }

  ///EVENT LOCATION
  Future<bool> setEventLocation(Map<String, dynamic> details) async {
    bool success = true;

    if (details == null || details.isEmpty) {
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
    event.streetAddress = details['address'];

    //set city
    event.city = details['cityName'];

    //get province
    event.province = details['province'];

    notifyListeners();

    return success;
  }

  setEventVenueName(String val) {
    event.venueName = val;
    notifyListeners();
  }

  setEventVenueSize(String val) {
    event.venueSize = val;
    notifyListeners();
  }

  ///EVENT DATA & TIME
  selectDate({@required bool selectingStartDate}) async {
    //set selectable dates
    Map<String, dynamic> customData = selectingStartDate
        ? {'minSelectedDate': DateTime.now().subtract(Duration(days: 1)), 'selectedDate': selectedStartDate}
        : {'minSelectedDate': selectedStartDate, 'selectedDate': selectedEndDate ?? selectedStartDate};
    var sheetResponse = await _bottomSheetService.showCustomSheet(
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

  onSelectedTimeFromDropdown({@required bool selectedStartTime, @required String time}) {
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
  toggleTicketForm({@required int ticketIndex}) {
    if (ticketIndex == null) {
      if (showTicketForm) {
        showTicketForm = false;
      } else {
        showTicketForm = true;
      }
    } else {
      showTicketForm = true;
      Map<String, dynamic> ticket = ticketDistro.tickets[ticketIndex];
      ticketNameTextController.text = ticket['ticketName'];
      ticketQuantityTextController.text = ticket['ticketQuantity'];
      ticketPriceTextController.text = ticket['ticketPrice'];
      ticketToEditIndex = ticketIndex;
    }
    notifyListeners();
  }

  addTicket() {
    if (ticketNameTextController.text.trim().isEmpty) {
      _snackbarService.showSnackbar(
        title: 'Ticket Name Required',
        message: 'Please add a name for this ticket',
        duration: Duration(seconds: 3),
      );
      return;
    } else if (ticketQuantityTextController.text.trim().isEmpty) {
      _snackbarService.showSnackbar(
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
      ticketDistro.tickets[ticketToEditIndex] = eventTicket;
      ticketToEditIndex = null;
    } else {
      ticketDistro.tickets.add(eventTicket);
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
      ticketDistro.tickets.removeAt(ticketToEditIndex);
      ticketToEditIndex = null;
    }
    notifyListeners();
  }

  //fees
  toggleFeeForm({@required int feeIndex}) {
    if (feeIndex == null) {
      if (showFeeForm) {
        showFeeForm = false;
      } else {
        showFeeForm = true;
      }
    } else {
      showFeeForm = true;
      Map<String, dynamic> fee = ticketDistro.fees[feeIndex];
      feeNameTextController.text = fee['feeName'];
      feePriceTextController.text = fee['feePrice'];
      feeToEditIndex = feeIndex;
    }
    notifyListeners();
  }

  addFee() {
    if (feeNameTextController.text.trim().isEmpty) {
      _snackbarService.showSnackbar(
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
      ticketDistro.fees[feeToEditIndex] = eventFee;
      feeToEditIndex = null;
    } else {
      ticketDistro.fees.add(eventFee);
    }
    showFeeForm = false;
    notifyListeners();
  }

  deleteFee() {
    feeNameTextController.clear();
    feePriceTextController.text = "\$0.00";
    showFeeForm = false;
    if (feeToEditIndex != null) {
      ticketDistro.fees.removeAt(feeToEditIndex);
      feeToEditIndex = null;
    }
    notifyListeners();
  }

  //discounts
  toggleDiscountsForm({@required int discountIndex}) {
    if (discountIndex == null) {
      if (showDiscountCodeForm) {
        showDiscountCodeForm = false;
      } else {
        showDiscountCodeForm = true;
      }
    } else {
      showDiscountCodeForm = true;
      Map<String, dynamic> discount = ticketDistro.discountCodes[discountIndex];
      discountNameTextController.text = discount['discountName'];
      discountLimitTextController.text = discount['discountLimit'];
      discountValueTextController.text = discount['discountValue'];
      discountToEditIndex = discountIndex;
    }
    notifyListeners();
  }

  addDiscount() {
    if (discountNameTextController.text.trim().isEmpty) {
      _snackbarService.showSnackbar(
        title: 'Discount Code Required',
        message: 'Please add a code for this discount',
        duration: Duration(seconds: 3),
      );
      return;
    } else if (discountLimitTextController.text.trim().isEmpty) {
      _snackbarService.showSnackbar(
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
      ticketDistro.discountCodes[discountToEditIndex] = eventDiscount;
      discountToEditIndex = null;
    } else {
      ticketDistro.discountCodes.add(eventDiscount);
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
      ticketDistro.discountCodes.removeAt(discountToEditIndex);
      discountToEditIndex = null;
    }
    notifyListeners();
  }

  ///ADDITIONAL EVENT INFO
  setVideoStreamStatus(bool val) {
    event.hasStream = val;
    notifyListeners();
  }

  setSponsorshipStatus(bool val) {
    event.openToSponsors = val;
    notifyListeners();
  }

  setFBUsername(String val) {
    event.fbUsername = val.trim();
    notifyListeners();
  }

  setInstaUsername(String val) {
    event.instaUsername = val.trim();
    notifyListeners();
  }

  setTwitterUsername(String val) {
    event.twitterUsername = val.trim();
    notifyListeners();
  }

  setWebsite(String val) {
    event.website = val.trim();
    notifyListeners();
  }

  ///FORM VALIDATION
  bool eventTagsAreValid() {
    if (event.tags == null || event.tags.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool eventTitleIsValid() {
    return isValidString(event.title);
  }

  bool eventDescIsValid() {
    return isValidString(event.description);
  }

  bool eventAddressIsValid() {
    return isValidString(event.streetAddress);
  }

  bool eventVenueNameIsValid() {
    return isValidString(event.venueName);
  }

  bool eventStartDateIsValid() {
    bool isValid = isValidString(event.startDate);
    if (isValid) {
      String eventStartDateAndTime = event.startDate + " " + event.startTime;
      event.startDateTimeInMilliseconds = dateTimeFormatter.parse(eventStartDateAndTime).millisecondsSinceEpoch;
      notifyListeners();
    }
    return isValid;
  }

  bool eventEndDateIsValid() {
    bool isValid = isValidString(event.endDate);
    if (isValid) {
      String eventEndDateAndTime = event.endDate + " " + event.endTime;
      event.endDateTimeInMilliseconds = dateTimeFormatter.parse(eventEndDateAndTime).millisecondsSinceEpoch;
      notifyListeners();
      if (event.endDateTimeInMilliseconds < event.startDateTimeInMilliseconds) {
        isValid = false;
      }
    }
    return isValid;
  }

  bool fbUsernameIsValid() {
    return isValidUsername(event.fbUsername);
  }

  bool instaUsernameIsValid() {
    return isValidUsername(event.instaUsername);
  }

  bool twitterUsernameIsValid() {
    return isValidUsername(event.twitterUsername);
  }

  bool websiteIsValid() {
    return isValidUrl(event.website);
  }

  bool formIsValid() {
    bool isValid = false;
    if (img == null && event.imageURL == null) {
      _snackbarService.showSnackbar(
        title: 'Event Image Error',
        message: 'Your event must have an image',
        duration: Duration(seconds: 3),
      );
    } else if (!eventTagsAreValid()) {
      _snackbarService.showSnackbar(
        title: 'Tag Error',
        message: 'Your event must contain at least 1 tag',
        duration: Duration(seconds: 3),
      );
    } else if (!eventTitleIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Event Title Required',
        message: 'The title for your event cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!eventDescIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Event Description Required',
        message: 'The description for your event cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!eventAddressIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Event Address Required',
        message: 'The address for your event cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!eventVenueNameIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Event Venue Name Required',
        message: 'The venue name for your event cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!eventStartDateIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Event Start Date Required',
        message: 'The start date & time for your event cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else if (!eventEndDateIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Event End Date Error',
        message: "End date & time must be set after the start date & time",
        duration: Duration(seconds: 5),
      );
    } else if (event.fbUsername != null && event.fbUsername.isNotEmpty && !fbUsernameIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Facebook Username Error',
        message: "Facebook username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (event.instaUsername != null && event.instaUsername.isNotEmpty && !instaUsernameIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Instagram Username Error',
        message: "Instagram username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (event.twitterUsername != null && event.twitterUsername.isNotEmpty && !twitterUsernameIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Twitter Username Error',
        message: "Twitter username must be valid",
        duration: Duration(seconds: 3),
      );
    } else if (event.website != null && event.website.isNotEmpty && !websiteIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Website URL Error',
        message: "Website URL must be valid",
        duration: Duration(seconds: 3),
      );
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<bool> submitNewEvent() async {
    bool success = true;

    //upload img if exists
    if (img != null) {
      String imageURL = await _firestoreStorageService.uploadImage(img: img, storageBucket: 'images', folderName: 'events', fileName: event.id);
      if (imageURL == null) {
        _snackbarService.showSnackbar(
          title: 'Event Upload Error',
          message: 'There was an issue uploading your event. Please try again.',
          duration: Duration(seconds: 3),
        );
        return false;
      }
      event.imageURL = imageURL;
    }

    //upload post data
    var uploadResult = await _eventDataService.createEvent(event: event);
    if (uploadResult is String) {
      _snackbarService.showSnackbar(
        title: 'Event Upload Error',
        message: 'There was an issue uploading your event. Please try again.',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    return success;
  }

  Future<bool> submitEditedEvent() async {
    bool success = true;

    // String message = postTextController.text.trim();
    //
    // //update post
    // post = WebblenPost(
    //   id: post.id,
    //   parentID: post.parentID,
    //   authorID: user.id,
    //   imageURL: img == null ? post.imageURL : null,
    //   body: message,
    //   nearbyZipcodes: post.nearbyZipcodes,
    //   city: post.city,
    //   province: post.province,
    //   followers: user.followers,
    //   tags: post.tags,
    //   webAppLink: post.webAppLink,
    //   sharedComs: post.sharedComs,
    //   savedBy: post.savedBy,
    //   postType: PostType.eventPost,
    //   postDateTimeInMilliseconds: post.postDateTimeInMilliseconds,
    //   paidOut: post.paidOut,
    //   participantIDs: post.participantIDs,
    //   commentCount: post.commentCount,
    //   reported: post.reported,
    // );
    //
    // //upload img if exists
    // if (img != null) {
    //   String imageURL = await _firestoreStorageService.uploadImage(img: img, storageBucket: 'images', folderName: 'posts', fileName: post.id);
    //   if (imageURL == null) {
    //     _snackbarService.showSnackbar(
    //       title: 'Post Upload Error',
    //       message: 'There was an issue uploading your post. Please try again.',
    //       duration: Duration(seconds: 3),
    //     );
    //     return false;
    //   }
    //   post.imageURL = imageURL;
    // }
    //
    // //upload post data
    // var uploadResult = await _postDataService.updatePost(post: post);
    // if (uploadResult is String) {
    //   _snackbarService.showSnackbar(
    //     title: 'Post Upload Error',
    //     message: 'There was an issue uploading your post. Please try again.',
    //     duration: Duration(seconds: 3),
    //   );
    //   return false;
    // }

    return success;
  }

  submitForm() async {
    setBusy(true);
    //if editing update post, otherwise create new post
    if (isEditing) {
      //update post
      bool submitted = await submitEditedEvent();
      if (submitted) {
        //show bottom sheet
        displayUploadSuccessBottomSheet();
      }
    } else {
      //submit new post
      bool submitted = await submitNewEvent();
      if (submitted) {
        //show bottom sheet
        displayUploadSuccessBottomSheet();
      }
    }
    setBusy(false);
  }

  showNewContentConfirmationBottomSheet({BuildContext context}) async {
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

    //display post confirmation
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      title: "Schedule Event?",
      description: event.privacy == "Public" ? "Schedule this event for everyone to see" : "Your event is ready to be scheduled and shared",
      mainButtonTitle: "Schedule Event",
      secondaryButtonTitle: "Cancel",
      customData: newEventTaxRate,
      variant: BottomSheetType.newContentConfirmation,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;

      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (res == "insufficient funds") {
        _snackbarService.showSnackbar(
          title: 'Insufficient Funds',
          message: 'You do no have enough WBLN to schedule this event',
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
    var sheetResponse = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.addContentSuccessful,
        takesInput: false,
        customData: event,
        barrierDismissible: false,
        title: "Your Event has been Scheduled! 🎉");
    if (sheetResponse == null || sheetResponse.responseData == "done") {
      _navigationService.pushNamedAndRemoveUntil(Routes.HomeNavViewRoute);
    }
  }

  ///NAVIGATION
  navigateBack() async {
    DialogResponse response = await _dialogService.showDialog(
      title: "Cancel Editing Event?",
      description: "The details for this event will not be saved",
      cancelTitle: "Cancel",
      cancelTitleColor: appDestructiveColor(),
      buttonTitle: "Continue Editing",
      buttonTitleColor: appTextButtonColor(),
      barrierDismissible: true,
    );
    if (response != null && !response.confirmed) {
      _navigationService.back();
    }
  }

  navigateBackToWalletPage() async {
    DialogResponse response = await _dialogService.showDialog(
      title: "Create an Earnings Account?",
      description: "The details for this event will not be saved",
      cancelTitle: "Continue Editing",
      cancelTitleColor: appTextButtonColor(),
      buttonTitle: "Create Earnings Account",
      buttonTitleColor: appTextButtonColor(),
      barrierDismissible: true,
    );
    if (response != null && response.confirmed) {
      _webblenBaseViewModel.setNavBarIndex(3);
      _navigationService.back();
    }
  }
}
