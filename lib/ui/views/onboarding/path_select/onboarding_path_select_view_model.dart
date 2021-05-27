import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class OnboardingPathSelectViewModel extends ReactiveViewModel {
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();
  LocationService _locationService = locator<LocationService>();
  UserDataService _userDataService = locator<UserDataService>();
  ThemeService _themeService = locator<ThemeService>();

  ///USER
  WebblenUser get user => _reactiveUserService.user;
  String emailAddress = "";
  bool isLoading = false;

  ///PERMISSIONS DATA
  bool notificationError = false;
  bool updatingLocation = false;
  bool locationError = false;
  bool hasLocation = false;
  String areaName = "The World";

  ///INTRO STATE
  final introKey = GlobalKey<IntroductionScreenState>();
  bool showSkipButton = true;
  bool showNextButton = true;
  bool freezeSwipe = false;
  int pageNum = 0;
  int imgFlex = 3;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  initialize() {
    setBusy(true);
    _themeService.setThemeMode(ThemeManagerMode.light);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    notifyListeners();
    setBusy(false);
  }

  updatePageNum(int val) {
    pageNum = val;
    notifyListeners();
  }

  updateImgFlex(int val) {
    imgFlex = val;
    notifyListeners();
  }

  updateShowNextButton(bool val) {
    showNextButton = val;
    notifyListeners();
  }

  updateEmail(String val) {
    emailAddress = val.trim();
    notifyListeners();
  }

  validateAndSubmitEmailAddress() {
    if (!isValidEmail(emailAddress)) {
      _customDialogService.showErrorDialog(description: "Invalid Email Address");
      return;
    } else {
      _userDataService.updateAssociatedEmailAddress(user.id!, emailAddress);
      introKey.currentState!.next();
    }
  }

  checkNotificationPermissions() async {
    bool hasPermission = await _permissionHandlerService.hasNotificationsPermission();
    if (hasPermission) {
      introKey.currentState!.next();
    } else {
      notificationError = true;
      notifyListeners();
    }
  }

  checkLocationPermissions() async {
    updatingLocation = true;
    notifyListeners();
    bool hasPermission = await _permissionHandlerService.hasLocationPermission();
    if (hasPermission) {
      String? val = await _locationService.getCurrentCity();
      if (val != null) {
        areaName = val;
        notifyListeners();
        introKey.currentState!.next();
      } else {
        locationError = true;
        notifyListeners();
      }
    } else {
      locationError = true;
      notifyListeners();
    }
    updatingLocation = false;
    notifyListeners();
  }

  openAppSettings() {
    openAppSettings();
  }

  navigateToNextPage() {
    introKey.currentState!.next();
  }

  navigateToPreviousPage() {
    introKey.currentState!.animateScroll(pageNum - 1);
  }

  transitionToEventHostPath() {
    _navigationService.navigateTo(Routes.EventHostPathViewRoute);
  }

  transitionToStreamerPath() {
    _navigationService.navigateTo(Routes.StreamerPathViewRoute);
  }

  transitionToExplorerPath() {
    _navigationService.navigateTo(Routes.ExplorerPathViewRoute);
  }
}
