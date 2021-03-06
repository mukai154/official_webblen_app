import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class ListProfileEventsModel extends ReactiveViewModel {
  EventDataService _eventDataService = locator<EventDataService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();
  String listKey = "initial-profile-events-key";
  String id = "";

  ///FILTER DATA
  String listAreaCode = "";
  String listTagFilter = "";
  String listSortByFilter = "Latest";

  String get cityName => _reactiveContentFilterService.areaCode;
  String get areaCode => _reactiveContentFilterService.areaCode;
  String get tagFilter => _reactiveContentFilterService.tagFilter;
  String get sortByFilter => _reactiveContentFilterService.sortByFilter;

  ///DATA
  List<DocumentSnapshot> dataResults = [];

  bool loadingAdditionalData = false;
  bool moreDataAvailable = true;

  int resultsLimit = 10;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveContentFilterService];

  initialize({required String uid, ScrollController? embeddedScrollController}) async {
    id = uid;

    notifyListeners();

    // get content filter
    syncContentFilter();

    _reactiveContentFilterService.addListener(() {
      if (areaCode != listAreaCode || listTagFilter != tagFilter || listSortByFilter != sortByFilter) {
        syncContentFilter();
        refreshData();
      }
    });

    await loadData();
  }

  syncContentFilter() {
    listAreaCode = areaCode;
    listTagFilter = listTagFilter;
    listSortByFilter = sortByFilter;
    notifyListeners();
  }

  Future<void> refreshData() async {
    //clear previous data
    dataResults = [];
    loadingAdditionalData = false;
    moreDataAvailable = true;

    notifyListeners();
    //load all data
    await loadData();
  }

  loadData() async {
    setBusy(true);

    //load data with params
    dataResults = await _eventDataService.loadEventsByUserID(
      id: id,
      resultsLimit: resultsLimit,
    );

    if (dataResults.length < resultsLimit) {
      moreDataAvailable = false;
    }
    notifyListeners();

    setBusy(false);
  }

  loadAdditionalData() async {
    //check if already loading data or no more data available
    if (loadingAdditionalData || !moreDataAvailable) {
      return;
    }

    //set loading additional data status
    loadingAdditionalData = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults = await _eventDataService.loadAdditionalEventsByUserID(
      id: id,
      lastDocSnap: dataResults[dataResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      moreDataAvailable = false;
    } else {
      dataResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalData = false;
    notifyListeners();
  }

  showContentOptions(dynamic content) async {
    String? val = await customBottomSheetService.showContentOptions(content: content);
    if (val != null && val == "deleted content") {
      dataResults.removeWhere((doc) => doc.id == content.id);
      listKey = getRandomString(5);
      notifyListeners();
    }
  }
}
