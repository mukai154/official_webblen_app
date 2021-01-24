import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/firestore/user_data_service.dart';
import 'package:webblen/ui/views/search/search_view.dart';

@singleton
class ExploreViewModel extends BaseViewModel {
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();

  ///HELPERS
  ScrollController streamScrollController = ScrollController();
  ScrollController eventScrollController = ScrollController();
  ScrollController userScrollController = ScrollController();

  ///DATA RESULTS
  String searchTerm;
  List<DocumentSnapshot> streamResults = [];
  bool loadingAdditionalStreams = false;
  bool moreStreamsAvailable = true;

  List<DocumentSnapshot> eventResults = [];
  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;

  List<DocumentSnapshot> userResults = [];
  bool loadingAdditionalUsers = false;
  bool moreUsersAvailable = true;

  int resultsLimit = 15;

  bool refreshingCauses = false;
  bool refreshingUsers = false;

  initialize() async {
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
    // streamResults = [];
    // notifyListeners();
    // await loadStreams();
  }

  loadStreams() async {
    // streamResults = await _algoliaSearchService.queryStreams(searchTerm: searchTerm, resultsLimit: resultsLimit);
    // streamResultsPageNum += 1;
    // notifyListeners();
  }

  loadAdditionalStreams() async {
    // if (loadingAdditionalStreams || !moreStreamsAvailable) {
    //   return;
    // }
    // loadingAdditionalStreams = true;
    // notifyListeners();
    // List<WebblenStream> newResults = await _algoliaSearchService.queryAdditionalStreams(
    //   searchTerm: searchTerm,
    //   resultsLimit: resultsLimit,
    //   pageNum: streamResultsPageNum,
    // );
    // if (newResults.length == 0) {
    //   moreStreamsAvailable = false;
    // } else {
    //   streamResults.addAll(newResults);
    //   streamResultsPageNum += 1;
    // }
    // loadingAdditionalStreams = false;
    // notifyListeners();
  }

  ///STREAMS
  Future<void> refreshEvents() async {
    // eventResults = [];
    // notifyListeners();
    // await loadEvents();
  }

  loadEvents() async {
    // eventResults = await _algoliaSearchService.queryEvents(searchTerm: searchTerm, resultsLimit: resultsLimit);
    // eventResultsPageNum += 1;
    // notifyListeners();
  }

  loadAdditionalEvents() async {
    // if (loadingAdditionalEvents || !moreEventsAvailable) {
    //   return;
    // }
    // loadingAdditionalEvents = true;
    // notifyListeners();
    // List<WebblenEvent> newResults = await _algoliaSearchService.queryAdditionalEvents(
    //   searchTerm: searchTerm,
    //   resultsLimit: resultsLimit,
    //   pageNum: streamResultsPageNum,
    // );
    // if (newResults.length == 0) {
    //   moreEventsAvailable = false;
    // } else {
    //   eventResults.addAll(newResults);
    //   eventResultsPageNum += 1;
    // }
    // loadingAdditionalStreams = false;
    // notifyListeners();
  }

  ///USERS
  Future<void> refreshUsers() async {
    // refreshingUsers = true;
    // userResults = [];
    // notifyListeners();
    // await loadUsers();
  }

  loadUsers() async {
    // userResults = await _userDataService.loadUsers(resultsLimit: resultsLimit);
    // refreshingUsers = false;
    // notifyListeners();
  }

  loadAdditionalUsers() async {
    // if (loadingAdditionalUsers || !moreUsersAvailable) {
    //   return;
    // }
    // loadingAdditionalUsers = true;
    // notifyListeners();
    // List<DocumentSnapshot> newResults = await _userDataService.loadAdditionalUsers(
    //   resultsLimit: resultsLimit,
    //   lastDocSnap: userResults[userResults.length - 1],
    // );
    // if (newResults.length == 0) {
    //   moreUsersAvailable = false;
    // } else {
    //   userResults.addAll(newResults);
    // }
    // loadingAdditionalUsers = false;
    // notifyListeners();
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//

  navigateToSearchView() {
    _navigationService.navigateWithTransition(SearchView(), transition: 'fade', opaque: true);
  }

  // navigateToCreateCauseView() {
  //   _navigationService.navigateTo(Routes.CreateCauseViewRoute);
  // }
}
