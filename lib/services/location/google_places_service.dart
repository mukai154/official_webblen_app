import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_google_places_api/flutter_google_places_api.dart';
import 'package:flutter_google_places_api/requests/place_autocomplete_request.dart';
import 'package:flutter_google_places_api/responses/place_autocomplete_response.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/services/location/location_service.dart';

class GooglePlacesService {
  LocationService _locationService = locator<LocationService>();

  Future googleSearchAutoComplete(
      {@required String key, @required String input}) async {
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

  Future<String> openGoogleAutoComplete(BuildContext context) async {
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: Strings.googleAPIKEY,
      //baseUrl: Strings.proxyMapsURL,
    );

    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: Strings.googleAPIKEY,
      onError: (res) {
        print(res.errorMessage);
      },
      //proxyBaseUrl: Strings.proxyMapsURL,
      mode: Mode.overlay,
      language: "en",
      components: [
        Component(
          Component.country,
          "us",
        ),
      ],
    );
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);

    String formattedAddressResponse = detail.result.formattedAddress;
    
    return formattedAddressResponse;
  }

  Future<Map<String, dynamic>> getDetailsFromPlaceID(
      {@required String key, @required String placeID}) async {
    Map<String, dynamic> details = {};
    PlaceDetailsResponse response = await PlaceDetailsRequest(
      key: key,
      placeId: placeID,
    ).call();
    if (response.status.errorMessage == null) {
      double lat = response.result.geometry.location.lat;
      double lon = response.result.geometry.location.lng;
      details['cityName'] =
          await _locationService.getCityNameFromLatLon(lat, lon);
      details['areaCode'] = await _locationService.getZipFromLatLon(lat, lon);
    }
    return details;
  }
}
