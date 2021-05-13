import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class ListCheckInEventsModel extends ReactiveViewModel {
  EventDataService _eventDataService = locator<EventDataService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  LocationService _locationService = locator<LocationService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();
  String listKey = "initial-check-in-events-key";

  ///FILTER DATA
  double? lat;
  double? lon;
  String get areaCode => _reactiveContentFilterService.areaCode;

  ///DATA
  List<DocumentSnapshot> dataResults = [];

  bool loadingAdditionalData = false;
  bool moreDataAvailable = true;

  int resultsLimit = 30;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveContentFilterService];

  initialize() async {
    await loadData();
  }

  Future<void> refreshData() async {
    scrollController.jumpTo(scrollController.position.minScrollExtent);

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

    //get current location
    bool hasLocationPermission = await _permissionHandlerService.hasLocationPermission();

    if (hasLocationPermission) {
      LocationData? locationData = await _locationService.getCurrentLocation();
      if (locationData != null) {
        lat = locationData.latitude;
        lon = locationData.longitude;

        //load data with params
        dataResults = await _eventDataService.loadNearbyEvents(areaCode: areaCode, lat: lat!, lon: lon!, resultsLimit: resultsLimit);

        if (dataResults.length < resultsLimit) {
          moreDataAvailable = false;
        }

        notifyListeners();
      }
    }

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

    //load additional data
    List<DocumentSnapshot> newResults = await _eventDataService.loadAdditionalNearbyEvents(
      areaCode: areaCode,
      lat: lat!,
      lon: lon!,
      lastDocSnap: dataResults[dataResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more data available
    if (newResults.length == 0) {
      moreDataAvailable = false;
    } else {
      dataResults.addAll(newResults);
    }

    //set loading additional data status
    loadingAdditionalData = false;
    notifyListeners();
  }

  showContentOptions(dynamic content) async {
    String val = await customBottomSheetService.showContentOptions(content: content);
    if (val == "deleted content") {
      dataResults.removeWhere((doc) => doc.id == content.id);
      listKey = getRandomString(5);
      notifyListeners();
    }
  }
}
