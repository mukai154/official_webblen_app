import 'dart:async';

import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/common/firebase_messaging_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/network_status.dart';

class AppBaseViewModel extends StreamViewModel<WebblenUser> with ReactiveServiceMixin {
  ///SERVICES
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService? _locationService = locator<LocationService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  DynamicLinkService? _dynamicLinkService = locator<DynamicLinkService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();

  ///INITIALIZATION DATA
  InitErrorStatus initErrorStatus = InitErrorStatus.none;

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;
  bool configuredMessaging = false;

  ///LOCATION DATA
  String get cityName => _reactiveContentFilterService.cityName;
  String get areaCode => _reactiveContentFilterService.areaCode;
  bool hasLocation = false;

  ///TAB BAR STATE
  int _navBarIndex = 0;
  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    notifyListeners();
  }

  ///STREAM USER DATA
  @override
  void onData(WebblenUser? data) {
    if (data != null) {
      if (!data.isValid()) {
        _reactiveUserService.updateUserLoggedIn(false);
        _reactiveUserService.updateUser(data);
        notifyListeners();
        setBusy(false);
      } else if (user != data) {
        _reactiveUserService.updateUser(data);
        _reactiveUserService.updateUserLoggedIn(true);
        if (!hasLocation) {
          getLocationDetails();
        }
        if (!configuredMessaging) {
          //configure firebase messaging
          FirebaseMessagingService().setDeviceMessagingToken(user.id);
          configuredMessaging = true;
        }
        notifyListeners();
        setBusy(false);
      }
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      WebblenUser streamedUser = WebblenUser();
      String? uid = user.id;
      if (uid != null) {
        streamedUser = await _userDataService.getWebblenUserByID(uid);
      }
      yield streamedUser;
    }
  }

  ///INITIALIZE DATA
  initialize() async {
    setBusy(true);

    //check network status
    bool connectedToNetwork = await isConnectedToNetwork();
    if (!connectedToNetwork) {
      initErrorStatus = InitErrorStatus.network;
      notifyListeners();
      _snackbarService!.showSnackbar(
        title: 'Network Error',
        message: "There Was an Issue Connecting to the Internet",
        duration: Duration(seconds: 5),
      );
      setBusy(false);
      return;
    }

    //check maintenance status
    bool underMaintenance = await _platformDataService.isUnderMaintenance();
    if (underMaintenance) {
      bool isAdmin = await _userDataService.checkIfCurrentUserIsAdmin(user.id!);
      if (!isAdmin) {
        initErrorStatus = InitErrorStatus.underMaintenance;
        notifyListeners();
        _snackbarService!.showSnackbar(
          title: 'Servers Currently Under Maintenance',
          message: "Please Try Again Later",
          duration: Duration(seconds: 5),
        );
        setBusy(false);
        return;
      }
    }

    //check update status
    bool updateRequired = await _platformDataService.isUpdateAvailable();
    if (updateRequired) {
      initErrorStatus = InitErrorStatus.underMaintenance;
      notifyListeners();
      _snackbarService!.showSnackbar(
        title: 'Update Required',
        message: "Please Update Webblen to Continue",
        duration: Duration(seconds: 5),
      );
      setBusy(false);
      return;
    }

    //check gps permissions
    bool locationGranted = await getLocationDetails();
    if (!locationGranted) {
      initErrorStatus = InitErrorStatus.location;
      notifyListeners();
      _snackbarService!.showSnackbar(
        title: 'Location Error',
        message: "There Was an Issue Getting Your Location",
        duration: Duration(seconds: 5),
      );
      setBusy(false);
      return;
    }

    //if there are no errors, check for dynamic links
    initErrorStatus = InitErrorStatus.none;
    await _dynamicLinkService!.handleDynamicLinks();
    notifyListeners();
    setBusy(false);
  }

  ///NETWORK STATUS
  Future<bool> isConnectedToNetwork() async {
    bool isConnected = await NetworkStatus().isConnected();
    return isConnected;
  }

  ///LOCATION
  Future<bool> getLocationDetails() async {
    bool hasLocationPermission = await _permissionHandlerService.hasLocationPermission();
    if (hasLocationPermission) {
      LocationData? location = await _locationService!.getCurrentLocation();
      if (location != null) {
        String? cityName = await _locationService!.getCityNameFromLatLon(location.latitude!, location.longitude!);
        if (cityName != null) {
          _reactiveContentFilterService.updateCityName(cityName);
        }

        String? areaCode = await _locationService!.getZipFromLatLon(location.latitude!, location.longitude!);
        if (areaCode != null) {
          _reactiveContentFilterService.updateAreaCode(areaCode);
          _userDataService.updateLastSeenZipcode(id: user.id, zip: areaCode);
        }

        hasLocation = true;

        notifyListeners();
      }
    }
    return hasLocationPermission;
  }
}
