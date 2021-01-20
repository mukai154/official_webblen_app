import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/post_data_service.dart';

@singleton
class HomeViewModel extends BaseViewModel {
  ///SERVICES
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
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

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  int resultsLimit = 15;

  openSearch() {}

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

  initialize({TabController tabController, WebblenUser currentUser, String initialCityName, String initialAreaCode}) async {
    user = currentUser;
    cityName = initialCityName;
    areaCode = initialAreaCode;
    notifyListeners();
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (tabController.index == 0) {
          loadAdditionalPosts();
        }
      }
    });
    notifyListeners();
    await loadData();
    setBusy(false);
  }

  loadData() async {
    await loadPosts();
  }

  Future<void> refreshData() async {
    setBusy(true);
    postResults = [];
    await loadData();
    notifyListeners();
    setBusy(false);
  }

  Future<void> refreshPosts() async {
    postResults = [];
    notifyListeners();
    await loadPosts();
  }

  loadPosts() async {
    postResults = await _postDataService.loadPosts(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );
    notifyListeners();
  }

  loadAdditionalPosts() async {
    if (loadingAdditionalPosts || !morePostsAvailable) {
      return;
    }
    loadingAdditionalPosts = true;
    notifyListeners();
    List<DocumentSnapshot> newResults = await _postDataService.loadAdditionalPosts(
      lastDocSnap: postResults[postResults.length - 1],
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );
    if (newResults.length == 0) {
      morePostsAvailable = false;
    } else {
      postResults.addAll(newResults);
    }
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
