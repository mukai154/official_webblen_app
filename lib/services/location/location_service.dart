import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:webblen/services_general/services_show_alert.dart';

class LocationService {
  Map<String, double> currentLocation;
  Location currentUserLocation = new Location();

  Future<LocationData> getCurrentLocation(BuildContext context) async {
    LocationData locationData;
    String error = "";
    try {
      locationData = await currentUserLocation.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Location Permission Denied';
        if (context != null) {
          ShowAlertDialogService().showFailureDialog(
            context,
            error,
            "Please Enable Location Services from Your App Settings to Find Events",
          );
        }
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Webblen Needs Permission to Access Your Location';
        if (context != null) {
          ShowAlertDialogService().showFailureDialog(
            context,
            error,
            "Please Enable Location Services from Your App Settings to Find Events",
          );
        }
      }
      locationData = null;
    }
    return locationData;
  }

  Future<List> findNearestZipcodes(String zipcode) async {
    List zips = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'findNearestZipcodes',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'zipcode': zipcode,
      },
    ).catchError((e) {
      print(e);
    });
    if (result != null) {
      List areaCodes = result.data['data'];
      if (areaCodes.isNotEmpty) {
        zips = areaCodes;
      }
    }
    return zips;
  }

  Future<Map<dynamic, dynamic>> reverseGeocodeLatLon(double lat, double lon) async {
    Map<dynamic, dynamic> data;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'reverseGeocodeLatLon',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
      },
    ).catchError((e) {
      print(e);
    });
    if (result != null) {
      data = result.data['data'][0];
    }
    return data;
  }

  Future<String> getAddressFromLatLon(double lat, double lon) async {
    String foundAddress;
    Coordinates coordinates = Coordinates(lat, lon);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var address = addresses.first;
    foundAddress = address.addressLine;
    return foundAddress;
  }

  Future<String> getZipFromLatLon(double lat, double lon) async {
    String zip;
    Coordinates coordinates = Coordinates(lat, lon);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var address = addresses.first;
    zip = address.postalCode;
    return zip;
  }

  Future<String> getCityNameFromLatLon(double lat, double lon) async {
    String cityName;
    Coordinates coordinates = Coordinates(lat, lon);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var address = addresses.first;
    cityName = address.locality;
    return cityName;
  }

  double getLatFromGeopoint(Map<dynamic, dynamic> geoP) {
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
