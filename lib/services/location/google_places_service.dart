import 'package:google_place/google_place.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/location/location_service.dart';

class GooglePlacesService {
  Future<Map<String, dynamic>> googleSearchAutoComplete({required String? key, required String input}) async {
    GooglePlace googlePlace = GooglePlace(key!);
    Map<String, dynamic> places = {};

    if (input.trim().isNotEmpty) {
      AutocompleteResponse? response = await googlePlace.autocomplete.get(input).catchError((e) {
        print(e);
      });

      if (response != null && response.predictions != null) {
        response.predictions!.forEach((res) {
          if (res.description != null) {
            places[res.description!] = res.placeId;
          }
        });
      }
    }

    return places;
  }

  Future<Map<String, dynamic>> getDetailsFromPlaceID({required String? key, required String placeID}) async {
    LocationService _locationService = locator<LocationService>();

    GooglePlace googlePlace = GooglePlace(key!);
    Map<String, dynamic> placeDetails = {};

    DetailsResponse? response = await googlePlace.details.get(placeID).catchError((e) {
      print(e);
    });

    if (response != null && response.result != null) {
      DetailsResult details = response.result!;
      double lat = details.geometry!.location!.lat!;
      double lon = details.geometry!.location!.lng!;
      placeDetails['lat'] = lat;
      placeDetails['lon'] = lon;
      placeDetails['streetAddress'] = details.formattedAddress;
      placeDetails['cityName'] = await _locationService.getCityNameFromLatLon(lat, lon);
      placeDetails['province'] = await _locationService.getProvinceFromLatLon(lat, lon);
      placeDetails['areaCode'] = await _locationService.getZipFromLatLon(lat, lon);
    }

    return placeDetails;
  }
}
