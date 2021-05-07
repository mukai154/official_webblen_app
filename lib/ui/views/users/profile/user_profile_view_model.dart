import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';

class UserProfileViewModel extends StreamViewModel<WebblenUser> {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  UserDataService? _userDataService = locator<UserDataService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  DynamicLinkService? _dynamicLinkService = locator<DynamicLinkService>();
  PostDataService? _postDataService = locator<PostDataService>();
  ShareService? _shareService = locator<ShareService>();
  NotificationDataService? _notificationDataService = locator<NotificationDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///DATA
  WebblenUser get currentUser => _reactiveUserService.user;

  ///UI HELPERS
  ScrollController scrollController = ScrollController();

  ///USER DATA
  String? uid;
  WebblenUser? user;
  bool? isFollowingUser;
  bool sendNotification = false;

  ///STREAM USER DATA
  @override
  void onData(WebblenUser? data) {
    if (data != null) {
      user = data;
      if (isFollowingUser == null) {
        if (user!.followers!.contains(currentUser.id)) {
          isFollowingUser = true;
        } else {
          isFollowingUser = false;
        }
      }
      notifyListeners();
      setBusy(false);
      //loadData();
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      if (uid != null) {
        await Future.delayed(Duration(seconds: 1));
        var res = await _userDataService!.getWebblenUserByID(uid);
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
    if (isFollowingUser!) {
      isFollowingUser = false;
      notifyListeners();
      bool followedUser = await _userDataService!.unFollowUser(currentUser!.id, user!.id);
      if (followedUser) {
        WebblenNotification notification = WebblenNotification().generateNewFollowerNotification(
          receiverUID: user!.id,
          senderUID: currentUser!.id,
          followerUsername: "@${currentUser!.username}",
        );
        _notificationDataService!.sendNotification(notif: notification);
        followedUser = true;
        notifyListeners();
      }
    } else {
      isFollowingUser = true;
      notifyListeners();
      _userDataService!.followUser(currentUser!.id, user!.id);
    }
  }

  showUserOptions() async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.userOptions,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "share profile") {
        //share profile
        String? url = await _dynamicLinkService!.createProfileLink(user: user!);
        _shareService!.shareLink(url);
      } else if (res == "message") {
        //message user
      } else if (res == "block") {
        //block user
      } else if (res == "report") {
        //report user
      }
      notifyListeners();
    }
  }
}
