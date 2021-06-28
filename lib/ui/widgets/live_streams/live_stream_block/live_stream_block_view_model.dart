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
import 'package:webblen/services/reactive/mini_video_player/reactive_mini_video_player_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view_model.dart';

class LiveStreamBlockViewModel extends BaseViewModel {
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  ReactiveMiniVideoPlayerService _reactiveMiniVideoPlayerService = locator<ReactiveMiniVideoPlayerService>();
  MiniVideoPlayerViewModel _miniVideoPlayerViewModel = locator<MiniVideoPlayerViewModel>();

  ///USER DATA
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
      if (stream.savedBy!.contains(user.id)) {
        savedStream = true;
      }
      savedBy = stream.savedBy!;
    }

    //check if user clicked content
    if (stream.clickedBy != null) {
      if (stream.clickedBy!.contains(user.id)) {
        clickedOnStream = true;
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

  navigateToStreamView({required WebblenLiveStream stream, required bool canOpenMiniVideoPlayer}) async {
    if (!clickedBy.contains(user.id)) {
      clickedBy.add(user.id);
      int clickCount = clickedBy.length;
      notifyListeners();
      _liveStreamDataService.addClick(uid: user.id, streamID: stream.id, clickCount: clickCount);
    }
    if (stream.muxAssetPlaybackID != null && stream.muxAssetPlaybackID!.isNotEmpty) {
      if (canOpenMiniVideoPlayer) {
        _reactiveMiniVideoPlayerService.updateSelectedStream(stream);
        _reactiveMiniVideoPlayerService.updateSelectedStreamCreator(hostUsername!);
        _miniVideoPlayerViewModel.initialize();
        _miniVideoPlayerViewModel.expandMiniPlayer();
      } else {
        customNavigationService.navigateToStandardVideoPlayer(stream.id!);
      }
    } else {
      customNavigationService.navigateToLiveStreamView(stream.id!);
    }
  }
}
