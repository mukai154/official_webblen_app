import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class EventCheckInBlockModel extends BaseViewModel {
  EventDataService _eventDataService = locator<EventDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///EVENT DATA
  WebblenEvent event = WebblenEvent();
  bool updatingCheckIn = false;
  bool eventIsHappeningNow = false;
  bool checkedIn = false;
  String? authorImageURL = "";
  String? authorUsername = "";

  initialize(WebblenEvent ev) async {
    setBusy(true);

    event = ev;
    notifyListeners();

    if (event.isValid()) {
      //check if user checked into event
      // List attendeeUIDs = event.attendees != null ? event.attendees!.keys.toList(growable: true) : [];
      List attendeeUIDs = event.attendees != null ? event.attendees! : [];
      if (attendeeUIDs.contains(user.id)) {
        checkedIn = true;
      }

      //check if event is happening now
      isEventHappeningNow(event);

      WebblenUser author = await _userDataService.getWebblenUserByID(event.authorID);
      if (author.isValid()) {
        authorImageURL = author.profilePicURL;
        authorUsername = author.username;
      }

      notifyListeners();
    }

    setBusy(false);
  }

  isEventHappeningNow(WebblenEvent event) {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = event.startDateTimeInMilliseconds!;
    int? eventEndDateInMilli = event.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli!) {
      eventIsHappeningNow = true;
    } else {
      eventIsHappeningNow = false;
    }
    notifyListeners();
  }

  checkInCheckoutOfEvent() async {
    isEventHappeningNow(event);
    if (eventIsHappeningNow) {
      updatingCheckIn = true;
      notifyListeners();
      if (checkedIn) {
        bool confirmedCheckout = await customBottomSheetService.showCheckoutEventDialog();
        if (confirmedCheckout) {
          bool checkedOut = await _eventDataService.checkOutOfEvent(user: user, eventID: event.id!);
          if (checkedOut) {
            checkedIn = false;
          }
        }
      } else {
        checkedIn = await _eventDataService.checkIntoEvent(user: user, eventID: event.id!);
      }
      updatingCheckIn = false;
      notifyListeners();
      HapticFeedback.lightImpact();
    } else {
      _customDialogService.showErrorDialog(description: "This event has already passed");
    }
  }
}
