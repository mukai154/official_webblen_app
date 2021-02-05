import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/firestore/platform_data_service.dart';

class LocationService {
  Map<String, double> currentLocation;
  Location currentUserLocation = Location();
  SnackbarService _snackbarService = locator<SnackbarService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();

  Future<LocationData> getCurrentLocation() async {
    LocationData locationData;
    try {
      locationData = await currentUserLocation.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        _snackbarService.showSnackbar(
          title: 'Error',
          message: "Please Enable Location Services from Your App Settings to Find Events",
          onTap: (val) => openAppSettings(),
          duration: Duration(seconds: 5),
        );
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        _snackbarService.showSnackbar(
          title: 'Error',
          message: "Please Enable Location Services from Your App Settings to Find Events",
          onTap: (val) => openAppSettings(),
          duration: Duration(seconds: 5),
        );
      }
      locationData = null;
    }
    return locationData;
  }

  Future<List> findNearestZipcodes(String zipcode) async {
    List zips = [];
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'findNearestZipcodes',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'zipcode': zipcode,
      },
    ).catchError((e) {
      //print(e);
    });
    if (result != null) {
      List areaCodes = result.data['data'];
      if (areaCodes != null && areaCodes.isNotEmpty) {
        zips = areaCodes;
      }
    }
    return zips;
  }

  Future<Map<dynamic, dynamic>> reverseGeocodeLatLon(double lat, double lon) async {
    Map<dynamic, dynamic> data;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'reverseGeocodeLatLon',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
      },
    ).catchError((e) {
      //print(e);
    });
    if (result != null) {
      data = result.data['data'][0];
    }
    return data;
  }

  Future<String> getAddressFromLatLon(double lat, double lon) async {
    String foundAddress;
    Coordinates coordinates = Coordinates(lat, lon);
    String googleAPIKey = await _platformDataService.getGoogleApiKey().catchError((e) {});
    var addresses = await Geocoder.google(googleAPIKey).findAddressesFromCoordinates(coordinates);
    var address = addresses.first;
    foundAddress = address.addressLine;
    return foundAddress;
  }

  Future<String> getZipFromLatLon(double lat, double lon) async {
    String zip;
    Coordinates coordinates = Coordinates(lat, lon);
    String googleAPIKey = await _platformDataService.getGoogleApiKey().catchError((e) {});
    var addresses = await Geocoder.google(googleAPIKey).findAddressesFromCoordinates(coordinates).catchError((e) {});
    var address = addresses.first;
    zip = address.postalCode;
    return zip;
  }

  Future<String> getCityNameFromLatLon(double lat, double lon) async {
    String cityName;
    Coordinates coordinates = Coordinates(lat, lon);
    String googleAPIKey = await _platformDataService.getGoogleApiKey().catchError((e) {});
    var addresses = await Geocoder.google(googleAPIKey).findAddressesFromCoordinates(coordinates);
    var address = addresses.first;
    cityName = address.locality;
    return cityName;
  }

  double getLatFromGeoPoint(Map<dynamic, dynamic> geoP) {
    double lat;
    List coordinates = geoP.values.toList();
    lat = coordinates[0];
    return lat == null ? 0.0 : lat;
  }

  double getLonFromGeopoint(Map<dynamic, dynamic> geoP) {
    double lon;
    List coordinates = geoP.values.toList();
    lon = coordinates[1];
    return lon == null ? 0.0 : lon;
  }
}
