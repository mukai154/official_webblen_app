import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class VerticalLiveStreamBlockViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  ///USER DATA
  bool get isLoggedIn => _reactiveUserService.userLoggedIn;
  WebblenUser get user => _reactiveUserService.user;

  bool savedStream = false;
  bool clickedOnStream = false;
  List savedBy = [];
  List clickedBy = [];
  String? hostImageURL = "";
  String? hostUsername = "";

  initialize(WebblenLiveStream stream) async {
    setBusy(true);

    //check if user saved content
    if (stream.savedBy != null) {
      if (isLoggedIn && user.isValid()) {
        if (stream.savedBy!.contains(user.id)) {
          savedStream = true;
        }
      }
      savedBy = stream.savedBy!;
    }

    //check if user clicked content
    if (stream.clickedBy != null) {
      if (isLoggedIn && user.isValid()) {
        if (stream.clickedBy!.contains(user.id)) {
          clickedOnStream = true;
        }
      }
      clickedBy = stream.clickedBy!;
    }

    WebblenUser author = await _userDataService.getWebblenUserByID(stream.hostID);
    if (author.isValid()) {
      hostImageURL = author.profilePicURL;
      hostUsername = author.username;
    }
    notifyListeners();
    setBusy(false);
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

  navigateToStreamView(WebblenLiveStream stream) async {
    if (!clickedBy.contains(user.id)) {
      clickedBy.add(user.id);
      int clickCount = clickedBy.length;
      notifyListeners();
      _liveStreamDataService.addClick(uid: user.id, streamID: stream.id, clickCount: clickCount);
    }
    if (stream.muxAssetPlaybackID != null && stream.muxAssetPlaybackID!.isNotEmpty) {
      //customNavigationService.navigateToRecordedLiveStreamView(stream.id!);
    } else {
      customNavigationService.navigateToLiveStreamView(stream.id!);
    }
  }

  navigateToUserView(String? id) {
    _navigationService.navigateTo(Routes.UserProfileView(id: id));
  }
}
