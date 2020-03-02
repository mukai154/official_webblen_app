import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';

class DeviceLocationService {
  Map<String, double> currentLocation;
  Location currentUserLocation = new Location();
  bool retrievedLocation = false;
  bool locationPermission = false;

  Future<bool> hasLocationPermission() async {
    bool hasAccess = true;
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    String status = permission.toString();
    if (status == 'PermissionStatus.unknown') {
      status = await DeviceLocationService().requestPermssion();
      if (status == 'PermissionStatus.denied') {
        hasAccess = false;
      }
    } else if (status == 'PermissionStatus.denied') {
      hasAccess = false;
    }
    return hasAccess;
  }

  Future<String> requestPermssion() async {
    PermissionStatus permission = await LocationPermissions().requestPermissions();
    return permission.toString();
  }

  Future<LocationData> getCurrentLocation(BuildContext context) async {
    LocationData locationData;
    String error = "";
    try {
      locationData = await currentUserLocation.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Location Permission Denied';
        if (context != null) {
//          ShowAlertDialogService().showFailureDialog(
//            context,
//            error,
//            "Please Enable Location Services from Your App Settings to Find Events",
//          );
        }
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Webblen Needs Permission to Access Your Location';
        if (context != null) {
//          ShowAlertDialogService().showFailureDialog(
//            context,
//            error,
//            "Please Enable Location Services from Your App Settings to Find Events",
//          );
        }
      }
      locationData = null;
    }
    return locationData;
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
