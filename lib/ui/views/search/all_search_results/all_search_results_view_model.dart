import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class AllSearchResultsViewModel extends BaseViewModel {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  AlgoliaSearchService? _algoliaSearchService = locator<AlgoliaSearchService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();

  ///HELPERS
  TextEditingController searchTextController = TextEditingController();
  ScrollController userScrollController = ScrollController();

  ///DATA RESULTS
  String? searchTerm;

  List<WebblenUser> userResults = [];
  bool loadingAdditionalUsers = false;
  bool moreUsersAvailable = true;
  int userResultsPageNum = 1;

  int resultsLimit = 15;

  initialize(String? term) async {
    searchTerm = term;
    searchTextController.text = searchTerm!;
    notifyListeners();
    userScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * userScrollController.position.maxScrollExtent;
      if (userScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalUsers();
      }
    });
    await loadUsers();
    setBusy(false);
  }

  ///USERS
  Future<void> refreshUsers() async {
    userResults = [];
    notifyListeners();
    await loadUsers();
  }

  loadUsers() async {
    userResults = await _algoliaSearchService!.queryUsers(searchTerm: searchTerm, resultsLimit: resultsLimit);
    userResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalUsers() async {
    if (loadingAdditionalUsers || !moreUsersAvailable) {
      return;
    }
    loadingAdditionalUsers = true;
    notifyListeners();
    List<WebblenUser> newResults = await _algoliaSearchService!.queryAdditionalUsers(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: userResultsPageNum,
    );
    if (newResults.length == 0) {
      moreUsersAvailable = false;
    } else {
      userResults.addAll(newResults);
      userResultsPageNum += 1;
    }
    loadingAdditionalUsers = false;
    notifyListeners();
  }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
