import 'package:flutter/material.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/location/location_service.dart';

class GooglePlacesService {
  LocationService? _locationService = locator<LocationService>();
  Future googleSearchAutoComplete({required String? key, required String input}) async {
    Map<String, dynamic> places = {};
    // PlaceAutocompleteResponse response = await PlaceAutocompleteRequest(
    //   key: key,
    //   input: input,
    // ).call();
    // response.predictions.forEach((res) {
    //   places[res.description] = res.placeId;
    // });
    return places;
  }

  Future<Map<String, dynamic>> getDetailsFromPlaceID({required String? key, required String? placeID}) async {
    Map<String, dynamic> details = {};
    // PlaceDetailsResponse response = await PlaceDetailsRequest(
    //   key: key,
    //   placeId: placeID,
    // ).call();
    // if (response.status.errorMessage == null) {
    //   double lat = response.result.geometry.location.lat;
    //   double lon = response.result.geometry.location.lng;
    //   details['lat'] = lat;
    //   details['lon'] = lon;
    //   details['address'] = response.result.formattedAddress;
    //   details['cityName'] = await _locationService.getCityNameFromLatLon(lat, lon);
    //   details['province'] = await _locationService.getProvinceFromLatLon(lat, lon);
    //   details['areaCode'] = await _locationService.getZipFromLatLon(lat, lon);
    // }
    return details;
  }
}
