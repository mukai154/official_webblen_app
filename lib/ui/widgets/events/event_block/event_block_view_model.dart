import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class EventBlockViewModel extends BaseViewModel {
  EventDataService _eventDataService = locator<EventDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  NavigationService _navigationService = locator<NavigationService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  bool eventIsHappeningNow = false;
  bool savedEvent = false;
  String? authorImageURL = "";
  String? authorUsername = "";

  initialize(WebblenEvent event) async {
    setBusy(true);

    //check if user saved event
    if (event.savedBy!.contains(_reactiveUserService.user.id)) {
      savedEvent = true;
    }

    //check if event is happening now
    isEventHappeningNow(event);

    WebblenUser author = await _userDataService.getWebblenUserByID(event.authorID);
    if (author.isValid()) {
      authorImageURL = author.profilePicURL;
      authorUsername = author.username;
    }

    notifyListeners();
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

  saveUnsaveEvent({String? eventID}) async {
    if (savedEvent) {
      savedEvent = false;
    } else {
      savedEvent = true;
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _eventDataService.saveUnsaveEvent(uid: user.id, eventID: eventID, savedEvent: savedEvent);
  }
}
