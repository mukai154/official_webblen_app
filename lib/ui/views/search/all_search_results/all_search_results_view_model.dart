import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_stream.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';

class AllSearchResultsViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  AlgoliaSearchService _algoliaSearchService = locator<AlgoliaSearchService>();

  ///HELPERS
  TextEditingController searchTextController = TextEditingController();
  ScrollController streamScrollController = ScrollController();
  ScrollController eventScrollController = ScrollController();
  ScrollController userScrollController = ScrollController();

  ///DATA RESULTS
  String searchTerm;
  List<WebblenStream> streamResults = [];
  bool loadingAdditionalStreams = false;
  bool moreStreamsAvailable = true;
  int streamResultsPageNum = 1;

  List<WebblenEvent> eventResults = [];
  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;
  int eventResultsPageNum = 1;

  List<WebblenUser> userResults = [];
  bool loadingAdditionalUsers = false;
  bool moreUsersAvailable = true;
  int userResultsPageNum = 1;

  int resultsLimit = 15;

  initialize(BuildContext context, String searchTermVal) async {
    searchTerm = searchTermVal;
    searchTextController.text = searchTerm;
    notifyListeners();
    streamScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * streamScrollController.position.maxScrollExtent;
      if (streamScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalStreams();
      }
    });
    eventScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * eventScrollController.position.maxScrollExtent;
      if (eventScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalEvents();
      }
    });
    userScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * userScrollController.position.maxScrollExtent;
      if (userScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalUsers();
      }
    });
    notifyListeners();
    await loadStreams();
    await loadEvents();
    await loadUsers();
    setBusy(false);
  }

  ///STREAMS
  Future<void> refreshStreams() async {
    streamResults = [];
    notifyListeners();
    await loadStreams();
  }

  loadStreams() async {
    streamResults = await _algoliaSearchService.queryStreams(searchTerm: searchTerm, resultsLimit: resultsLimit);
    streamResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalStreams() async {
    if (loadingAdditionalStreams || !moreStreamsAvailable) {
      return;
    }
    loadingAdditionalStreams = true;
    notifyListeners();
    List<WebblenStream> newResults = await _algoliaSearchService.queryAdditionalStreams(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: streamResultsPageNum,
    );
    if (newResults.length == 0) {
      moreStreamsAvailable = false;
    } else {
      streamResults.addAll(newResults);
      streamResultsPageNum += 1;
    }
    loadingAdditionalStreams = false;
    notifyListeners();
  }

  ///STREAMS
  Future<void> refreshEvents() async {
    eventResults = [];
    notifyListeners();
    await loadEvents();
  }

  loadEvents() async {
    eventResults = await _algoliaSearchService.queryEvents(searchTerm: searchTerm, resultsLimit: resultsLimit);
    eventResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalEvents() async {
    if (loadingAdditionalEvents || !moreEventsAvailable) {
      return;
    }
    loadingAdditionalEvents = true;
    notifyListeners();
    List<WebblenEvent> newResults = await _algoliaSearchService.queryAdditionalEvents(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: streamResultsPageNum,
    );
    if (newResults.length == 0) {
      moreEventsAvailable = false;
    } else {
      eventResults.addAll(newResults);
      eventResultsPageNum += 1;
    }
    loadingAdditionalStreams = false;
    notifyListeners();
  }

  ///USERS
  Future<void> refreshUsers() async {
    userResults = [];
    notifyListeners();
    await loadUsers();
  }

  loadUsers() async {
    userResults = await _algoliaSearchService.queryUsers(searchTerm: searchTerm, resultsLimit: resultsLimit);
    userResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalUsers() async {
    if (loadingAdditionalUsers || !moreUsersAvailable) {
      return;
    }
    loadingAdditionalUsers = true;
    notifyListeners();
    List<WebblenUser> newResults = await _algoliaSearchService.queryAdditionalUsers(
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

  ///NAVIGATION
  navigateToPreviousPage() {
    _navigationService.back();
  }

  navigateToHomePage() {
    _navigationService.popRepeated(2);
  }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
