import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/url_handler.dart';

class UserProfileViewModel extends StreamViewModel<WebblenUser> {
  UserDataService _userDataService = locator<UserDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  ///DATA
  WebblenUser get currentUser => _reactiveUserService.user;

  ///UI HELPERS
  ScrollController scrollController = ScrollController();

  ///USER DATA
  String? uid;
  WebblenUser? user;
  bool? isFollowingUser;
  bool? mutedUser;
  bool sendNotification = false;

  ///STREAM USER DATA
  @override
  void onData(WebblenUser? data) {
    if (data != null) {
      user = data;
      if (isFollowingUser == null) {
        if (user!.followers != null && user!.followers!.contains(currentUser.id)) {
          isFollowingUser = true;
        } else {
          isFollowingUser = false;
        }
      }
      if (mutedUser == null) {
        if (user!.mutedBy != null && user!.mutedBy!.contains(currentUser.id)) {
          mutedUser = true;
        } else {
          mutedUser = false;
        }
      }
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      if (uid != null) {
        await Future.delayed(Duration(seconds: 1));
        var res = await _userDataService.getWebblenUserByID(uid);
        if (res is String) {
        } else {
          yield res;
        }
      }
    }
  }

  ///INITIALIZE
  initialize({String? id}) async {
    setBusy(true);
    uid = id;
    notifyListeners();
  }

  ///FOLLOW UNFOLLOW USER
  followUnfollowUser() async {
    if (user!.id == currentUser.id) {
      _customDialogService.showErrorDialog(description: "You cannot follow yourself");
    } else if (isFollowingUser!) {
      isFollowingUser = false;
      notifyListeners();
      await _userDataService.unFollowUser(currentUser.id, user!.id);
    } else {
      isFollowingUser = true;
      notifyListeners();
      bool followedUser = await _userDataService.followUser(currentUser.id, user!.id);
      if (followedUser) {
        WebblenNotification notification = WebblenNotification().generateNewFollowerNotification(
          receiverUID: user!.id,
          senderUID: currentUser.id,
          followerUsername: "@${currentUser.username}",
        );
        _notificationDataService.sendNotification(notif: notification);
        notifyListeners();
      }
    }
  }

  ///MUTE UNMUTE USER
  muteUnmuteUser() async {
    if (user!.id == currentUser.id) {
      _customDialogService.showErrorDialog(description: "You cannot mute notifications from yourself");
    } else if (mutedUser!) {
      mutedUser = false;
      notifyListeners();
      await _userDataService.unMuteUser(currentUser.id, user!.id);
    } else {
      mutedUser = true;
      notifyListeners();
      await _userDataService.muteUser(currentUser.id, user!.id);
    }
  }

  viewWebsite() {
    UrlHandler().launchInWebViewOrVC(user!.website!);
  }

  showUserOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.userOptions,
      customData: {'muted': mutedUser},
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "share profile") {
        //share profile
        String? url = await _dynamicLinkService.createProfileLink(user: user!);
        _shareService.shareLink(url);
      } else if (res == "message") {
        //message user
      } else if (res == "block") {
        //block user
      } else if (res == "report") {
        //report user
      } else if (res == "mute" || res == "unmute") {
        muteUnmuteUser();
      }
      notifyListeners();
    }
  }
}
