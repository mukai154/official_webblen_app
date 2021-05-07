import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/add_to_calendar.dart';
import 'package:webblen/utils/url_handler.dart';

class EventViewModel extends ReactiveViewModel {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  UserDataService? _userDataService = locator<UserDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  TicketDistroDataService? _ticketDistroDataService = locator<TicketDistroDataService>();
  LocationService? _locationService = locator<LocationService>();
  CommentDataService? _commentDataService = locator<CommentDataService>();
  NotificationDataService? _notificationDataService = locator<NotificationDataService>();
  CustomDialogService customDialogService = locator<CustomDialogService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///HOST
  WebblenUser? host;
  bool isHost = false;

  ///EVENT
  WebblenEvent? event;
  bool hasSocialAccounts = false;
  bool liveNow = false;
  bool eventPassed = false;

  ///TICKETS
  WebblenTicketDistro? ticketDistro;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  ///INITIALIZE
  initialize(String eventID) async {
    setBusy(true);

    // .value will return the raw string value
    String id = eventID;

    //get stream data
    var res = await _eventDataService.getEventByID(id);
    if (!res.isValid()) {
      customNavigationService.navigateBack();
      return;
    } else {
      event = res;
    }

    //check if stream is live
    isHappeningNow();

    //get tickets if they exist
    if (event!.hasTickets!) {
      ticketDistro = await _ticketDistroDataService!.getTicketDistroByID(event!.id);
    }

    //check if stream has social accounts
    if ((event!.fbUsername != null && event!.fbUsername!.isNotEmpty) ||
        (event!.instaUsername != null && event!.instaUsername!.isNotEmpty) ||
        (event!.twitterUsername != null && event!.twitterUsername!.isNotEmpty) ||
        (event!.website != null && event!.website!.isNotEmpty)) {
      hasSocialAccounts = true;
    }

    //get author info
    host = await _userDataService!.getWebblenUserByID(event!.authorID);

    if (user.id == event!.authorID) {
      isHost = true;
    }

    notifyListeners();
    setBusy(false);
  }

  isHappeningNow() {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = event!.startDateTimeInMilliseconds!;
    int? eventEndDateInMilli = event!.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli!) {
      liveNow = true;
    } else {
      liveNow = false;
    }
    if (currentDateInMilli > eventEndDateInMilli!) {
      eventPassed = true;
    }
    print(liveNow);
    notifyListeners();
  }

  addToCalendar() async {
    bool hasPermission = await _permissionHandlerService.hasCalendarPermission();
    if (hasPermission) {
      addEventToCalendar(webblenEvent: event!);
    }
  }

  openMaps() {
    _locationService!.openMaps(address: event!.streetAddress!);
  }

  openFacebook() {
    if (event!.fbUsername != null) {
      String url = "https://facebook.com/${event!.fbUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openInstagram() {
    if (event!.instaUsername != null) {
      String url = "https://instagram.com/${event!.instaUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openTwitter() {
    if (event!.twitterUsername != null) {
      String url = "https://twitter.com/${event!.twitterUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openWebsite() {
    if (event!.website != null) {
      String url = event!.website!;
      UrlHandler().launchInWebViewOrVC(url);
    }
  }
}
