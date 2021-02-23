import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/redeemed_reward_data_service.dart';

@singleton
class RedeemedRewardsViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  RedeemedRewardDataService _redeemedRewardDataService =
      locator<RedeemedRewardDataService>();

  //HELPERS
  ScrollController scrollController = ScrollController();

  ///DATA RESULTS
  List<DocumentSnapshot> redeemedRewardResults = [];
  DocumentSnapshot lastRedeemedRewardDocSnap;

  bool loadingRedeemedRewards = true;
  bool loadingAdditionalRedeemedRewards = false;
  bool moreRedeemedRewardsAvailable = true;

  int resultsLimit = 10;

  ///INITIALIZE
  initialize(BuildContext context) async {
    setBusy(true);

    Map<String, dynamic> args = RouteData.of(context).arguments;
    WebblenUser currentUser = args['currentUser'] ?? "";

    //load additional content on scroll
    scrollController.addListener(() {
      double triggerFetchMoreSize =
          0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalRedeemedRewards(currentUser);
      }
    });
    notifyListeners();

    //load content data
    await loadData(currentUser);
    setBusy(false);
  }

  ///LOAD ALL DATA
  loadData(WebblenUser user) async {
    await loadRedeemedRewards(user);
  }

  // ///REFRESH ALL DATA
  // Future<void> refreshData(WebblenUser user) async {
  //   //set busy status
  //   setBusy(true);

  //   //clear previous data
  //   redeemedRewardResults = [];

  //   //load all data
  //   await loadData(user);
  //   notifyListeners();

  //   //set busy status
  //   setBusy(false);
  // }

  ///POST DATA
  Future<void> refreshRedeemedRewards(BuildContext context) async {
    Map<String, dynamic> args = RouteData.of(context).arguments;
    WebblenUser currentUser = args['currentUser'] ?? "";

    //set loading posts status
    loadingRedeemedRewards = true;

    //clear previous post data
    redeemedRewardResults = [];
    notifyListeners();

    //load posts
    await loadRedeemedRewards(currentUser);
  }

  loadRedeemedRewards(WebblenUser user) async {
    //load posts with params
    redeemedRewardResults =
        await _redeemedRewardDataService.loadUserRedeemedRewards(
      uid: user.id,
      resultsLimit: resultsLimit,
    );

    //set loading posts status
    loadingRedeemedRewards = false;
    notifyListeners();
  }

  loadAdditionalRedeemedRewards(WebblenUser user) async {
    //check if already loading posts or no more posts available
    if (loadingAdditionalRedeemedRewards || !moreRedeemedRewardsAvailable) {
      return;
    }

    //set loading additional posts status
    loadingAdditionalRedeemedRewards = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults =
        await _redeemedRewardDataService.loadAdditionalUserRedeemedRewards(
      uid: user.id,
      lastDocSnap: redeemedRewardResults[redeemedRewardResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      moreRedeemedRewardsAvailable = false;
    } else {
      redeemedRewardResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalRedeemedRewards = false;
    notifyListeners();
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
