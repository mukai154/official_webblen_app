import 'package:permission_handler/permission_handler.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';

class PermissionHandlerService {
  Future<bool> hasCameraPermission() async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();

    bool hasPermission = false;
    PermissionStatus status = await Permission.camera.status.catchError((e) {
      print(e);
    });
    if (status.isGranted || status.isLimited) {
      hasPermission = true;
    } else if (status.isDenied) {
      status = await Permission.contacts.request();
      if (status.isGranted) {
        hasPermission = true;
      }
    } else {
      _customDialogService.showAppSettingsDialog(
        title: "Camera Permission Required",
        description: "Please open your app settings and enable your camera",
      );
      return hasPermission;
    }
    return hasPermission;
  }

  Future<bool> hasPhotosPermission() async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();

    bool hasPermission = false;
    PermissionStatus status = await Permission.photos.status.catchError((e) {
      print(e);
    });
    if (status.isGranted || status.isLimited) {
      hasPermission = true;
    } else if (status.isDenied) {
      status = await Permission.photos.request();
      if (status.isGranted) {
        hasPermission = true;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      _customDialogService.showAppSettingsDialog(
        title: "Photos Permission Required",
        description: "Please open your app settings and enable access to your photos",
      );
      return hasPermission;
    }
    return hasPermission;
  }

  Future<bool> hasMicrophonePermission() async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();

    bool hasPermission = false;
    PermissionStatus status = await Permission.microphone.status.catchError((e) {
      print(e);
    });
    if (status.isGranted || status.isLimited) {
      hasPermission = true;
    } else if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        hasPermission = true;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      print("denied");
      _customDialogService.showAppSettingsDialog(
        title: "Microphone Permission Required",
        description: "Please open your app settings and enable your microphone",
      );
      return hasPermission;
    }
    return hasPermission;
  }

  Future<bool> hasCalendarPermission() async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();

    bool hasPermission = false;
    PermissionStatus status = await Permission.calendar.status.catchError((e) {
      print(e);
    });
    ;
    if (status.isGranted || status.isLimited) {
      hasPermission = true;
    } else if (status.isDenied) {
      status = await Permission.calendar.request();
      if (status.isGranted) {
        hasPermission = true;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      _customDialogService.showAppSettingsDialog(
        title: "Calendar Permission Required",
        description: "Please open your app settings and enable your access to your calendar",
      );
      return hasPermission;
    }
    return hasPermission;
  }

  Future<bool> hasLocationPermission() async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();
    bool hasPermission = false;
    PermissionStatus status = await Permission.location.status.catchError((e) {
      print(e);
    });
    if (status.isGranted || status.isLimited) {
      hasPermission = true;
    } else if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isGranted) {
        hasPermission = true;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      _customDialogService.showAppSettingsDialog(
        title: "Location Permission Required",
        description: "Please open your app settings and enable your access and enable access to your location",
      );
      return hasPermission;
    }
    return hasPermission;
  }

  Future<bool> hasNotificationsPermission() async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();

    bool hasPermission = false;
    PermissionStatus status = await Permission.notification.status.catchError((e) {
      print(e);
    });
    if (status.isGranted || status.isLimited) {
      hasPermission = true;
    } else if (status.isDenied) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        hasPermission = true;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      _customDialogService.showAppSettingsDialog(
        title: "Notifications Are Disabled",
        description: "Open your app settings and enable notifications",
      );
      return hasPermission;
    }
    return hasPermission;
  }
}
