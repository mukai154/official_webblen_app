import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
import 'package:webblen/utils/add_to_calendar.dart';
import 'package:webblen/utils/url_handler.dart';

class EventViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  UserDataService _userDataService = locator<UserDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  LocationService _locationService = locator<LocationService>();
  CommentDataService _commentDataService = locator<CommentDataService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  WebblenBaseViewModel _webblenBaseViewModel = locator<WebblenBaseViewModel>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  ///EVENT AUTHOR
  WebblenUser author;
  bool isAuthor = false;

  ///EVENT
  WebblenEvent event;
  bool hasSocialAccounts = false;
  bool eventIsHappeningNow = false;

  ///TICKETS
  WebblenTicketDistro ticketDistro;

  ///INITIALIZE
  initialize(BuildContext context) async {
    setBusy(true);

    Map<String, dynamic> args = RouteData.of(context).arguments;
    String eventID = args['id'] ?? "";

    //get event data
    var res = await _eventDataService.getEventByID(eventID);
    if (res == null) {
      _navigationService.back();
      return;
    } else {
      event = res;
    }

    //check if event is happening now
    isEventHappeningNow(event);

    //get tickets if they exist
    if (event.hasTickets) {
      ticketDistro = await _ticketDistroDataService.getTicketDistroByID(event.id);
    }

    //check if event has social accounts
    if ((event.fbUsername != null && event.fbUsername.isNotEmpty) ||
        (event.instaUsername != null && event.instaUsername.isNotEmpty) ||
        (event.twitterUsername != null && event.twitterUsername.isNotEmpty) ||
        (event.website != null && event.website.isNotEmpty)) {
      hasSocialAccounts = true;
    }
    //get author info
    author = await _userDataService.getWebblenUserByID(event.authorID);

    if (_webblenBaseViewModel.uid == event.authorID) {
      isAuthor = true;
    }

    notifyListeners();
    setBusy(false);
  }

  isEventHappeningNow(WebblenEvent event) {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = event.startDateTimeInMilliseconds;
    int eventEndDateInMilli = event.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli) {
      eventIsHappeningNow = true;
    } else {
      eventIsHappeningNow = false;
    }
    notifyListeners();
  }

  addToCalendar() {
    addEventToCalendar(webblenEvent: event);
  }

  openMaps() {
    _locationService.openMaps(address: event.streetAddress);
  }

  openFacebook() {
    if (event.fbUsername != null) {
      String url = "https://facebook.com/${event.fbUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openInstagram() {
    if (event.instaUsername != null) {
      String url = "https://instagram.com/${event.instaUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openTwitter() {
    if (event.twitterUsername != null) {
      String url = "https://twitter.com/${event.twitterUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openWebsite() {
    if (event.website != null) {
      String url = event.website;
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  ///DIALOGS & BOTTOM SHEETS
  showContentOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: isAuthor ? BottomSheetType.contentAuthorOptions : BottomSheetType.contentOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "edit") {
        //edit
        _navigationService.navigateTo(Routes.CreateEventViewRoute, arguments: {
          'id': event.id,
        });
      } else if (res == "share") {
        //share
        WebblenUser author = await _userDataService.getWebblenUserByID(event.authorID);
        String url = await _dynamicLinkService.createEventLink(authorUsername: author.username, event: event);
        _shareService.shareLink(url);
      } else if (res == "report") {
        //report
        _eventDataService.reportEvent(eventID: event.id, reporterID: _webblenBaseViewModel.uid);
      } else if (res == "delete") {
        //delete
        deleteContentConfirmation();
      }
    }
  }

  deleteContentConfirmation() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Delete Event",
      description: "Are You Sure You Want to Delete this Event?",
      mainButtonTitle: "Delete Event",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "confirmed") {
        await _eventDataService.deleteEvent(event: event);
        _navigationService.back();
      }
    }
  }

  ///NAVIGATION
  navigateToUserView(String id) {
    _navigationService.navigateTo(Routes.UserProfileView, arguments: {'id': id});
  }

// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
