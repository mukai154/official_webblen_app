import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class LiveStreamBlockViewModel extends BaseViewModel {
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  bool isLive = false;
  bool savedStream = false;
  List savedBy = [];
  String? hostImageURL = "";
  String? hostUsername = "";

  initialize(WebblenLiveStream stream) async {
    setBusy(true);

    //check if user saved event
    if (stream.savedBy != null) {
      if (stream.savedBy!.contains(user.id)) {
        savedStream = true;
      }
      savedBy = stream.savedBy!;
    } else {
      savedBy = [];
    }

    //check if event is happening now
    isStreamLive(stream);

    WebblenUser author = await _userDataService.getWebblenUserByID(stream.hostID);
    if (author.isValid()) {
      hostImageURL = author.profilePicURL;
      hostUsername = author.username;
    }
    notifyListeners();
    setBusy(false);
  }

  isStreamLive(WebblenLiveStream stream) {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = stream.startDateTimeInMilliseconds!;
    int? eventEndDateInMilli = stream.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli!) {
      isLive = true;
    } else {
      isLive = false;
    }
    notifyListeners();
  }

  saveUnsaveStream({required WebblenLiveStream stream}) async {
    if (savedStream) {
      savedStream = false;
      savedBy.remove(user.id);
    } else {
      savedStream = true;
      savedBy.add(user.id);
      WebblenNotification notification = WebblenNotification().generateContentSavedNotification(
        receiverUID: stream.hostID!,
        senderUID: user.id!,
        username: user.username!,
        content: stream,
      );
      _notificationDataService.sendNotification(notif: notification);
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _liveStreamDataService.saveUnsaveStream(uid: user.id!, streamID: stream.id!, savedStream: savedStream);
  }
}
