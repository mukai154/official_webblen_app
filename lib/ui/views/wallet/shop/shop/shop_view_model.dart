import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/reward_type.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/reward_data_service.dart';

@singleton
class ShopViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  RewardDataService _rewardDataService = locator<RewardDataService>();

  //HELPERS
  ScrollController webblenClothesScrollController = ScrollController();
  ScrollController cashScrollController = ScrollController();

  ///DATA RESULTS
  List<DocumentSnapshot> webblenClothesRewardResults = [];
  List<DocumentSnapshot> cashRewardResults = [];

  DocumentSnapshot lastWebblenClothesRewardDocSnap;
  DocumentSnapshot lastCashRewardDocSnap;

  bool loadingWebblenClothesRewards = true;
  bool loadingAdditionalWebblenClothesRewards = false;
  bool moreWebblenClothesRewardsAvailable = true;

  bool loadingCashRewards = true;
  bool loadingAdditionalCashRewards = false;
  bool moreCashRewardsAvailable = true;

  int resultsLimit = 5;

  WebblenUser user;

  ///INITIALIZE
  void initialize(BuildContext context) async {
    setBusy(true);

    Map<String, dynamic> args = RouteData.of(context).arguments;
    WebblenUser currentUser = args['currentUser'] ?? "";

    user = currentUser;

    //load additional content on scroll
    webblenClothesScrollController.addListener(() {
      double triggerFetchMoreSize =
          0.1 * webblenClothesScrollController.position.maxScrollExtent;
      if (webblenClothesScrollController.position.pixels >
          triggerFetchMoreSize) {
        print('triggered');
        loadAdditionalWebblenClothesRewards();
      }
    });
    notifyListeners();

    //load additional content on scroll
    cashScrollController.addListener(() {
      double triggerFetchMoreSize =
          0.9 * cashScrollController.position.maxScrollExtent;
      if (cashScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalCashRewards();
      }
    });
    notifyListeners();

    //load content data
    await loadData();
    setBusy(false);
  }

  ///LOAD ALL DATA
  Future loadData() async {
    await loadWebblenClothesRewards();
    await loadCashRewards();
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

  Future loadWebblenClothesRewards() async {
    //load posts with params
    webblenClothesRewardResults = await _rewardDataService.loadRewardsByType(
      rewardType: RewardType.webblenClothes,
      resultsLimit: resultsLimit,
    );

    //set loading posts status
    loadingWebblenClothesRewards = false;
    notifyListeners();
  }

  Future loadCashRewards() async {
    //load posts with params
    cashRewardResults = await _rewardDataService.loadRewardsByType(
      rewardType: RewardType.cash,
      resultsLimit: resultsLimit,
    );

    //set loading posts status
    loadingCashRewards = false;
    notifyListeners();
  }

  Future loadAdditionalWebblenClothesRewards() async {
    //check if already loading posts or no more posts available
    if (loadingAdditionalWebblenClothesRewards ||
        !moreWebblenClothesRewardsAvailable) {
      return;
    }

    //set loading additional posts status
    loadingAdditionalWebblenClothesRewards = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults =
        await _rewardDataService.loadAdditionalRewardsByType(
      rewardType: RewardType.webblenClothes,
      lastDocSnap:
          webblenClothesRewardResults[webblenClothesRewardResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      moreWebblenClothesRewardsAvailable = false;
    } else {
      webblenClothesRewardResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalWebblenClothesRewards = false;
    notifyListeners();
  }

  Future loadAdditionalCashRewards() async {
    //check if already loading posts or no more posts available
    if (loadingAdditionalCashRewards || !moreCashRewardsAvailable) {
      return;
    }

    //set loading additional posts status
    loadingAdditionalCashRewards = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults =
        await _rewardDataService.loadAdditionalRewardsByType(
      rewardType: RewardType.cash,
      lastDocSnap: cashRewardResults[cashRewardResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      moreCashRewardsAvailable = false;
    } else {
      cashRewardResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalCashRewards = false;
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

  void navigateToShopItemView(WebblenUser user, WebblenReward reward) {
    _navigationService.navigateTo(
      Routes.ShopItemViewRoute,
      arguments: {'currentUser': user, 'relevantReward': reward},
    );
  }
}
