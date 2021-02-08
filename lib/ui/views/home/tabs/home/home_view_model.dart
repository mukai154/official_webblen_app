import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/platform_data_service.dart';
import 'package:webblen/services/firestore/post_data_service.dart';

@singleton
class HomeViewModel extends BaseViewModel {
  ///SERVICES
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  PostDataService _postDataService = locator<PostDataService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();
  int dateTimeInMilliseconds1MonthAgo = DateTime.now().millisecondsSinceEpoch - 2628000000;

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
      variant: BottomSheetType.homeFilter,
      takesInput: true,
      customData: {
        'currentCityName': cityName,
        'currentAreaCode': areaCode,
        'currentSortBy': sortBy,
        'currentTagFilter': tagFilter,
      },
    );
    if (sheetResponse.responseData != null) {
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

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToCreateCauseView() {
    //_navigationService.navigateTo(Routes.CreateCauseViewRoute);
  }
}
