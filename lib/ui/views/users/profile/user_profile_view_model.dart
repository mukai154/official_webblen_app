import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';

class UserProfileViewModel extends StreamViewModel<WebblenUser> {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  PostDataService _postDataService = locator<PostDataService>();
  ShareService _shareService = locator<ShareService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();

  ///UI HELPERS
  ScrollController scrollController = ScrollController();

  ///DATA
  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;
  bool reloadingPosts = false;

  int resultsLimit = 20;

  ///USER DATA
  String uid;
  WebblenUser currentUser;
  WebblenUser user;
  bool isFollowingUser;
  bool sendNotification = false;

  ///STREAM USER DATA
  @override
  void onData(WebblenUser data) {
    if (data != null) {
      user = data;
      if (isFollowingUser == null) {
        if (user.followers.contains(currentUser.id)) {
          isFollowingUser = true;
        } else {
          isFollowingUser = false;
        }
      }
      notifyListeners();
      loadData();
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      if (uid == null) {
        yield null;
      }
      await Future.delayed(Duration(seconds: 1));
      var res = await _userDataService.getWebblenUserByID(uid);
      if (res is String) {
        yield null;
      } else {
        yield res;
      }
    }
  }

  ///INITIALIZE
  initialize({BuildContext context, TabController tabController}) async {
    //set busy status
    setBusy(true);

    //get current user
    String currentUID = await _authService.getCurrentUserID();
    currentUser = await _userDataService.getWebblenUserByID(currentUID);
    notifyListeners();

    //get user
    Map<String, dynamic> args = RouteData.of(context).arguments;
    uid = args['id'] ?? "";
    notifyListeners();

    //load additional data on scroll
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (tabController.index == 0) {
          loadAdditionalPosts();
        }
      }
    });
    notifyListeners();

    //load profile data
  }

  loadData() async {
    await loadPosts();
    notifyListeners();
    setBusy(false);
  }

  Future<void> refreshPosts() async {
    await loadPosts();
    notifyListeners();
  }

  ///Load Data
  loadPosts() async {
    //load posts with params
    postResults = await _postDataService.loadPostsByUserID(id: user.id, resultsLimit: resultsLimit);
  }

  loadAdditionalPosts() async {
    //check if already loading posts or no more posts available
    if (loadingAdditionalPosts || !morePostsAvailable) {
      return;
    }

    //set loading additional posts status
    loadingAdditionalPosts = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults = await _postDataService.loadAdditionalPostsByUserID(
      lastDocSnap: postResults[postResults.length - 1],
      id: user.id,
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      morePostsAvailable = false;
    } else {
      postResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalPosts = false;
    notifyListeners();
  }

  ///FOLLOW UNFOLLOW USER
  followUnfollowUser() async {
    if (isFollowingUser) {
      isFollowingUser = false;
      notifyListeners();
      bool followedUser = await _userDataService.unFollowUser(currentUser.id, user.id);
      if (followedUser) {
        WebblenNotification notification = WebblenNotification().generateNewFollowerNotification(
          receiverUID: user.id,
          senderUID: currentUser.id,
          followerUsername: "@${currentUser.username}",
        );
        _notificationDataService.sendNotification(notif: notification);
        followedUser = true;
        notifyListeners();
      }
    } else {
      isFollowingUser = true;
      notifyListeners();
      _userDataService.followUser(currentUser.id, user.id);
    }
  }

  ///BOTTOM SHEETS
  showUserOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.userOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "share profile") {
        //share profile
        String url = await _dynamicLinkService.createProfileLink(user: user);
        _shareService.shareLink(url);
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

  //show content options
  showContentOptions({BuildContext context, dynamic content}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.contentOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "edit") {
        //edit post
        _navigationService.navigateTo(Routes.CreatePostViewRoute, arguments: {
          'id': content.id,
        });
      } else if (res == "share") {
        //share post link
        String url = await _dynamicLinkService.createPostLink(authorUsername: user.username, post: content);
        _shareService.shareLink(url);
      } else if (res == "report") {
        //report post
        _postDataService.reportPost(postID: content.id, reporterID: user.id);
      }
      notifyListeners();
    }
  }

  ///NAVIGATION
  navigateToCreatePostPage({dynamic args}) {
    if (args == null) {
      _navigationService.navigateTo(Routes.CreatePostViewRoute, arguments: args);
    } else {
      _navigationService.navigateTo(Routes.CreatePostViewRoute);
    }
  }

  navigateToEditProfileView() {
    _navigationService.navigateTo(Routes.EditProfileViewRoute, arguments: {'id': user.id});
  }

  navigateToSettingsView() {
    _navigationService.navigateTo(Routes.SettingsViewRoute);
  }
}
