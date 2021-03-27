import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/models/search_result.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
import 'package:webblen/ui/views/home/tabs/search/recent_search_view_model.dart';

import 'all_search_results/all_search_results_view.dart';

class SearchViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  AlgoliaSearchService _algoliaSearchService = locator<AlgoliaSearchService>();
  UserDataService _userDataService = locator<UserDataService>();
  RecentSearchViewModel _recentSearchViewModel = locator<RecentSearchViewModel>();
  WebblenBaseViewModel webblenBaseViewModel = locator<WebblenBaseViewModel>();

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

  initialize({String term}) async {
    setBusy(true);

    //check if user clicked recently searched term
    if (term != null && term.trim().isNotEmpty) {
      searchTextController.text = term;
      querySearchResults(term);
    }

    //get recent search
    recentSearchTerms = _recentSearchViewModel.recentSearchTerms;

    notifyListeners();
    setBusy(false);
  }

  querySearchResults(String searchTerm) async {
    await Future.delayed(Duration(seconds: 1));
    if (searchTextController.text != searchTerm) {
      return;
    }
    setBusy(true);
    if (searchTerm == null || searchTerm.trim().isEmpty) {
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
      _algoliaSearchService.storeSearchTerm(uid: webblenBaseViewModel.uid, searchTerm: searchTerm);
      await _navigationService.navigateWithTransition(AllSearchResultsView(searchTerm: searchTerm), transition: 'fade', opaque: true);
      searchTextController.selection = TextSelection(baseOffset: 0, extentOffset: searchTextController.text.length);
      FocusScope.of(context).previousFocus();
    }
  }

  navigateToCauseView(String id) {
    //_navigationService.navigateTo(Routes.CauseViewRoute, arguments: {'id': id});
  }

  navigateToUserView(Map<String, dynamic> userData) {
    _algoliaSearchService.storeSearchTerm(uid: webblenBaseViewModel.uid, searchTerm: userData['username']);
    _navigationService.navigateTo(Routes.UserProfileView, arguments: {'id': userData['id']});
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
