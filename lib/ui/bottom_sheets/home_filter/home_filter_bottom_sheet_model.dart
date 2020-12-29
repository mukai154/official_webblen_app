import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/firestore/platform_data_service.dart';
import 'package:webblen/services/location/google_places_service.dart';

class HomeFilterBottomSheetModel extends BaseViewModel {
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  GooglePlacesService googlePlacesService = locator<GooglePlacesService>();
  AlgoliaSearchService algoliaSearchService = locator<AlgoliaSearchService>();

  TextEditingController locationTextController = TextEditingController();
  TextEditingController tagTextController = TextEditingController();

  String sortBy;
  List<String> sortByList = ["Latest", "Most Popular"];
  String tagFilter;
  Map<String, dynamic> placeSearchResults = {};
  String cityName;
  String areaCode;
  String googleAPIKey;

  initialize(String currentSortBy, String currentCity, String currentAreaCode, String currentTagFilter) async {
    sortBy = currentSortBy;
    cityName = currentCity;
    areaCode = currentAreaCode;
    tagFilter = currentTagFilter;
    tagTextController.text = tagFilter;
    locationTextController.text = cityName;
    notifyListeners();
    googleAPIKey = await _platformDataService.getGoogleApiKey();
    notifyListeners();
  }

  setPlacesSearchResults(Map<String, dynamic> res) {
    placeSearchResults = res;
    notifyListeners();
  }

  getPlaceDetails(String place) async {
    String placeID = placeSearchResults[place];
    googlePlacesService.getDetailsFromPlaceID(key: googleAPIKey, placeID: placeID);
    Map<String, dynamic> details = await googlePlacesService.getDetailsFromPlaceID(key: googleAPIKey, placeID: placeID);
    if (details.isNotEmpty) {
      cityName = details['cityName'];
      areaCode = details['areaCode'];
      locationTextController.text = cityName;
      notifyListeners();
    } else {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: "There was an issue getting the details of this location. Please Try Again.",
        duration: Duration(seconds: 5),
      );
    }
  }

  setTagFilter(String val) async {
    tagFilter = val;
    tagTextController.text = val;
    notifyListeners();
  }

  Map<String, dynamic> returnPreferences() {
    return {
      "sortBy": sortBy,
      "cityName": cityName,
      "areaCode": areaCode,
      "tagFilter": tagFilter,
    };
  }
}
