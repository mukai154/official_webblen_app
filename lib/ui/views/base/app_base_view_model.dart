import 'dart:async';

import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/common/firebase_messaging_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view_model.dart';
import 'package:webblen/utils/network_status.dart';

class AppBaseViewModel extends StreamViewModel<WebblenUser> with ReactiveServiceMixin {
  ///SERVICES
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService? _locationService = locator<LocationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();
  MiniVideoPlayerViewModel _miniVideoPlayerViewModel = locator<MiniVideoPlayerViewModel>();

  ///INITIALIZATION DATA
  InitErrorStatus initErrorStatus = InitErrorStatus.none;

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;
  bool configuredMessaging = false;

  ///LOCATION DATA
  bool hasLocation = false;

  ///TAB BAR STATE
  int _navBarIndex = 0;
  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    if (_miniVideoPlayerViewModel.isExpanded) {
      _miniVideoPlayerViewModel.shrinkMiniPlayer();
    }
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
      } else if (!user.isIdenticalTo(data)) {
        print(true);
        _reactiveUserService.updateUser(data);
        _reactiveUserService.updateUserLoggedIn(true);
        if (!hasLocation) {
          getLocationDetails();
        }
        if (!configuredMessaging) {
          //configure firebase messaging && app open
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
  initialize(String? page) async {
    setBusy(true);

    if (page != null && page.isNotEmpty) {
      try {
        int pageNum = int.parse(page);
        setNavBarIndex(pageNum);
        notifyListeners();
      } catch (e) {}
    }

    //check network status
    bool connectedToNetwork = await isConnectedToNetwork();
    if (!connectedToNetwork) {
      initErrorStatus = InitErrorStatus.network;
      notifyListeners();
      _customDialogService.showDetailedErrorDialog(
        title: 'Network Error',
        description: "There Was an Issue Connecting to the Internet",
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
        _customDialogService.showDetailedErrorDialog(
          title: 'Servers Currently Under Maintenance',
          description: "Please Try Again Later",
        );
        setBusy(false);
        return;
      }
    }

    //check update status
    bool updateRequired = await _platformDataService.isUpdateAvailable();
    if (updateRequired) {
      initErrorStatus = InitErrorStatus.updateRequired;
      notifyListeners();
      _customDialogService.showDetailedErrorDialog(
        title: 'Update Required',
        description: "Please Update Webblen to Continue",
      );
      setBusy(false);
      return;
    }

    //check gps permissions
    bool locationGranted = await getLocationDetails();
    if (!locationGranted) {
      initErrorStatus = InitErrorStatus.location;
      notifyListeners();
      _customDialogService.showDetailedErrorDialog(
        title: 'Location Error',
        description: "There Was an Issue Getting Your Location",
      );
      setBusy(false);
      return;
    }

    //if there are no errors, check for dynamic links
    initErrorStatus = InitErrorStatus.none;
    await _dynamicLinkService.handleVariousAppLinks();
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
          _userDataService.updateUserAppOpen(uid: user.id!, zipcode: areaCode);
        }

        hasLocation = true;

        notifyListeners();
      }
    }
    return hasLocationPermission;
  }
}
