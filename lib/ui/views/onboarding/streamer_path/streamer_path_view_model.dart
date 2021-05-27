import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';

class StreamerPathViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  AlgoliaSearchService _algoliaSearchService = locator<AlgoliaSearchService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  UserDataService _userDataService = locator<UserDataService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();

  ///USER
  WebblenUser get user => _reactiveUserService.user;

  ///TAG INFO
  Map<dynamic, dynamic> allTags = {};
  String selectedCategory = 'select category';
  List selectedTags = [];
  List<String> tagCategories = [];

  ///STRIPE
  late String stripeConnectURL;

  ///INTRO STATE
  final introKey = GlobalKey<IntroductionScreenState>();
  bool showSkipButton = true;
  bool showNextButton = true;
  int pageNum = 0;

  initialize() async {
    setBusy(true);
    _algoliaSearchService.getTagsAndCategories().then((res) {
      allTags = res;
      allTags.keys.forEach((key) {
        if (key != null) {
          tagCategories.add(key.toString());
        }
      });
      tagCategories.sort((a, b) => a.compareTo(b));
      tagCategories.insert(0, "select category");
      selectedCategory = tagCategories.first;
    });
    notifyListeners();
    setBusy(false);
  }

  createStripeAccount() {
    _stripeConnectAccountService.createStripeConnectAccount(uid: user.id!);
  }

  updatePageNum(int val) {
    pageNum = val;
    notifyListeners();
  }

  updateShowNextButton(bool val) {
    showNextButton = val;
    notifyListeners();
  }

  updateSelectedCategory(String val) {
    selectedCategory = val;
    notifyListeners();
  }

  updateSelectedTags(String val) {
    if (selectedTags.contains(val)) {
      selectedTags.remove(val);
    } else {
      selectedTags.add(val);
    }
    notifyListeners();
  }

  navigateToNextPage() {
    introKey.currentState!.next();
  }

  navigateToPreviousPage() {
    introKey.currentState!.animateScroll(pageNum - 1);
  }

  navigateToMonetizePage() {
    introKey.currentState!.animateScroll(1);
  }

  skipToSelectInterest() {
    introKey.currentState!.animateScroll(3);
  }

  completeOnboarding() {
    WebblenUser updatedUserVal = user;
    updatedUserVal.tags = selectedTags;
    _reactiveUserService.updateUser(updatedUserVal);
    _userDataService.updateInterests(user.id!, selectedTags);
    _navigationService.pushNamedAndRemoveUntil(Routes.SuggestAccountsViewRoute);
  }

  navigateToSelectPath() {
    _navigationService.back();
  }
}
