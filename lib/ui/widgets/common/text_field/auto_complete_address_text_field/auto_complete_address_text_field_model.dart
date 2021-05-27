import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/location/google_places_service.dart';

class AutoCompleteAddressTextFieldModel extends BaseViewModel {
  ///SERVICES
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  GooglePlacesService googlePlacesService = locator<GooglePlacesService>();

  ///HELPERS
  TextEditingController locationTextController = TextEditingController();

  ///RESULTS
  bool settingLocation = false;
  Map<String, dynamic> placeSearchResults = {};

  ///API KEYS
  String? googleAPIKey;

  ///INITIALIZE
  initialize({required String initialValue}) async {
    locationTextController.text = initialValue;
    notifyListeners();
    googleAPIKey = await _platformDataService.getGoogleApiKey();
    notifyListeners();
  }

  ///SET RESULTS
  setPlacesSearchResults(Map<String, dynamic> val) {
    placeSearchResults = val;
    notifyListeners();
  }

  ///GET LOCATION DETAILS
  Future<Map<String, dynamic>> getPlaceDetails(String place) async {
    locationTextController.text = "Setting Location...";
    settingLocation = true;
    notifyListeners();

    Map<String, dynamic> result = {};
    String? placeID = placeSearchResults[place];

    await googlePlacesService.getDetailsFromPlaceID(key: googleAPIKey, placeID: placeID!).then((details) {
      if (details.isEmpty) {
        _customDialogService.showErrorDialog(
          description: "There was an issue getting the details of this location. Please Try Again.",
        );
      } else {
        result = details;
      }
    });
    settingLocation = false;
    locationTextController.text = place;
    notifyListeners();

    return result;
  }
}
