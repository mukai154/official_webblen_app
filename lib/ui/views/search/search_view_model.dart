import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/search_result.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

import 'all_search_results/all_search_results_view.dart';

class SearchViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  AlgoliaSearchService _algoliaSearchService = locator<AlgoliaSearchService>();
  UserDataService _userDataService = locator<UserDataService>();

  ///HELPERS
  TextEditingController searchTextController = TextEditingController();

  ///SEARCH
  List recentSearchTerms = [];
  List<SearchResult> streamResults = [];
  List<SearchResult> eventResults = [];
  List<SearchResult> userResults = [];

  int streamResultsLimit = 5;
  int eventResultsLimit = 5;
  int userResultsLimit = 16;

  ///DATA
  String uid;

  initialize() async {
    setBusy(true);
    uid = await _authService.getCurrentUserID();
    recentSearchTerms = await _algoliaSearchService.getRecentSearchTerms(uid: uid);
    notifyListeners();
    setBusy(false);
  }

  querySearchResults(String searchTerm) async {
    setBusy(true);
    if (searchTerm == null || searchTerm.trim().isEmpty) {
      await Future.delayed(Duration(seconds: 2));
      streamResults = [];
      eventResults = [];
      userResults = [];
    } else {
      streamResults = await _algoliaSearchService.searchStreams(searchTerm: searchTerm, resultsLimit: streamResultsLimit);
      eventResults = await _algoliaSearchService.searchEvents(searchTerm: searchTerm, resultsLimit: eventResultsLimit);
      userResults = await _algoliaSearchService.searchUsers(searchTerm: searchTerm, resultsLimit: userResultsLimit);
    }
    notifyListeners();
    setBusy(false);
  }

  ///NAVIGATION
  viewAllResultsForSearchTerm({BuildContext context, String searchTerm}) async {
    if (searchTerm.trim().isNotEmpty) {
      searchTextController.text = searchTerm;
      notifyListeners();
      _algoliaSearchService.storeSearchTerm(uid: uid, searchTerm: searchTerm);
      await _navigationService.navigateWithTransition(AllSearchResultsView(searchTerm: searchTerm), transition: 'fade', opaque: true);
      searchTextController.selection = TextSelection(baseOffset: 0, extentOffset: searchTextController.text.length);
      FocusScope.of(context).previousFocus();
    }
  }

  navigateToCauseView(String id) {
    //_navigationService.navigateTo(Routes.CauseViewRoute, arguments: {'id': id});
  }

  navigateToUserView(String uid) {
    //_navigationService.navigateTo(Routes.UserViewRoute, arguments: {'uid': uid});
  }

  navigateToPreviousView() {
    _navigationService.popRepeated(1);
  }
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
