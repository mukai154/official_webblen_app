import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';

@singleton
class HomeViewModel extends BaseViewModel {
  ///SERVICES
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  PostDataService _postDataService = locator<PostDataService>();
  ShareService _shareService = locator<ShareService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();

  ///CURRENT USER
  WebblenUser user;

  ///FILTERS
  String cityName;
  String areaCode;
  String sortBy = "Latest";
  String tagFilter = "";

  ///DATA RESULTS
  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingPosts = true;
  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  int resultsLimit = 10;

  ///PROMOS
  double postPromo;
  double streamPromo;
  double eventPromo;

  openFilter() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.homeFilter,
      takesInput: true,
      customData: {
        'currentCityName': cityName,
        'currentAreaCode': areaCode,
        'currentSortBy': sortBy,
        'currentTagFilter': tagFilter,
      },
    );
    if (sheetResponse != null && sheetResponse.responseData != null) {
      cityName = sheetResponse.responseData['cityName'];
      areaCode = sheetResponse.responseData['areaCode'];
      sortBy = sheetResponse.responseData['sortBy'];
      tagFilter = sheetResponse.responseData['tagFilter'];
      notifyListeners();
      refreshData();
    }
  }

  ///INITIALIZE
  initialize({TabController tabController, WebblenUser currentUser, String initialCityName, String initialAreaCode}) async {
    //get current user
    user = currentUser;

    //get location data
    cityName = initialCityName;
    areaCode = initialAreaCode;

    //load content promos (if any exists)
    postPromo = await _platformDataService.getPostPromo();
    streamPromo = await _platformDataService.getStreamPromo();
    eventPromo = await _platformDataService.getEventPromo();

    //load additional content on scroll
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (tabController.index == 0) {
          loadAdditionalPosts();
        }
      }
    });
    notifyListeners();

    //load content data
    await loadData();
    setBusy(false);
  }

  ///LOAD ALL DATA
  loadData() async {
    await loadPosts();
  }

  ///REFRESH ALL DATA
  Future<void> refreshData() async {
    //set busy status
    setBusy(true);

    //clear previous data
    postResults = [];

    //load all data
    await loadData();
    notifyListeners();

    //set busy status
    setBusy(false);
  }

  ///POST DATA
  Future<void> refreshPosts() async {
    //set loading posts status
    loadingPosts = true;

    //clear previous post data
    postResults = [];
    notifyListeners();

    //load posts
    await loadPosts();
  }

  loadPosts() async {
    //load posts with params
    postResults = await _postDataService.loadPosts(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //set loading posts status
    loadingPosts = false;
    notifyListeners();
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
    List<DocumentSnapshot> newResults = await _postDataService.loadAdditionalPosts(
      lastDocSnap: postResults[postResults.length - 1],
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
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
  //bottom sheet for new post, stream, or event
  showAddContentOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.addContent,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "new post") {
        navigateToCreatePostPage();
      } else if (res == "new stream") {
        //
      } else if (res == "new event") {
        //
      }
      notifyListeners();
    }
  }

  //show post options
  showPostOptions({BuildContext context, WebblenPost post}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: user.id == post.authorID ? BottomSheetType.postAuthorOptions : BottomSheetType.postOptions,
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
      } else if (res == "delete") {
        //delete
        deletePostConfirmation(context: context, post: post);
      }
      notifyListeners();
    }
  }

  //show delete post confirmation
  deletePostConfirmation({BuildContext context, WebblenPost post}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Delete Post",
      description: "Are You Sure You Want to Delete this Post?",
      mainButtonTitle: "Delete Post",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "confirmed") {
        _postDataService.deletePost(post: post);
        postResults.removeWhere((doc) => doc.id == post.id);
        notifyListeners();
      }
    }
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToCreatePostPage() {
    _navigationService.navigateTo(Routes.CreatePostViewRoute);
  }
}
