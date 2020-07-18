import 'package:location_permissions/location_permissions.dart';

class DevicePermissions {
  Future<String> checkLocationPermissions() async {
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    return permission.toString();
  }

  Future<String> requestPermssion() async {
    PermissionStatus permission = await LocationPermissions().requestPermissions();
    return permission.toString();
  }
}
