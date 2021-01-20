import 'package:auto_route/auto_route.dart';
import 'package:flutter_google_places_api/flutter_google_places_api.dart';
import 'package:flutter_google_places_api/requests/place_autocomplete_request.dart';
import 'package:flutter_google_places_api/responses/place_autocomplete_response.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/location/location_service.dart';

class GooglePlacesService {
  LocationService _locationService = locator<LocationService>();
  Future googleSearchAutoComplete({@required String key, @required String input}) async {
    Map<String, dynamic> places = {};
    PlaceAutocompleteResponse response = await PlaceAutocompleteRequest(
      key: key,
      input: input,
    ).call();
    response.predictions.forEach((res) {
      places[res.description] = res.placeId;
    });
    return places;
  }

  Future<Map<String, dynamic>> getDetailsFromPlaceID({@required String key, @required String placeID}) async {
    Map<String, dynamic> details = {};
    PlaceDetailsResponse response = await PlaceDetailsRequest(
      key: key,
      placeId: placeID,
    ).call();
    if (response.status.errorMessage == null) {
      double lat = response.result.geometry.location.lat;
      double lon = response.result.geometry.location.lng;
      details['cityName'] = await _locationService.getCityNameFromLatLon(lat, lon);
      details['areaCode'] = await _locationService.getZipFromLatLon(lat, lon);
    }
    return details;
  }
}
