import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';

class UserProfileViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  PostDataService _postDataService = locator<PostDataService>();
  ShareService _shareService = locator<ShareService>();

  ///UI HELPERS
  ScrollController scrollController = ScrollController();

  ///DATA
  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;
  bool reloadingPosts = false;

  int resultsLimit = 20;

  WebblenUser user;

  ///INITIALIZE
  initialize({BuildContext context, TabController tabController}) async {
    //set busy status
    setBusy(true);

    //get user
    Map<String, dynamic> args = RouteData.of(context).arguments;
    String uid = args['id'] ?? "";
    user = await _userDataService.getWebblenUserByID(uid);
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
    await loadData();
    setBusy(false);
  }

  loadData() async {
    await loadPosts();
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

  //show post options
  showPostOptions({BuildContext context, WebblenPost post}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.postOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "edit") {
        //edit post
        _navigationService.navigateTo(Routes.CreatePostViewRoute, arguments: {
          'postID': post.id,
        });
      } else if (res == "share") {
        //share post link
        String url = await _dynamicLinkService.createPostLink(postAuthorUsername: "@${user.username}", post: post);
        _shareService.shareLink(url);
      } else if (res == "report") {
        //report post
        _postDataService.reportPost(postID: post.id, reporterID: user.id);
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
