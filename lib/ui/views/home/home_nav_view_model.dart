import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/utils/network_status.dart';

class HomeNavViewModel extends StreamViewModel<WebblenUser> {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();

  InitErrorStatus initErrorStatus = InitErrorStatus.network;
  WebblenUser user;
  String initialCityName;
  String initialAreaCode;

  //Tab Bar State
  int _navBarIndex = 0;
  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    notifyListeners();
  }

  initialize() async {
    setBusy(true);
    isConnectedToNetwork().then((connected) {
      if (!connected) {
        initErrorStatus = InitErrorStatus.network;
        setBusy(false);
        notifyListeners();
        _snackbarService.showSnackbar(
          title: 'Network Error',
          message: "There Was an Issue Connecting to the Internet",
          duration: Duration(seconds: 5),
        );
      } else {
        getLocationDetails().then((e) {
          if (e != null) {
            initErrorStatus = InitErrorStatus.location;
            setBusy(false);
            notifyListeners();
            _snackbarService.showSnackbar(
              title: 'Location Error',
              message: "There Was an Issue Getting Your Location",
              duration: Duration(seconds: 5),
            );
          } else {
            initErrorStatus = InitErrorStatus.none;
            setBusy(false);
            notifyListeners();
          }
        });
      }
    });
  }

  Future<bool> isConnectedToNetwork() async {
    bool isConnected = await NetworkStatus().isConnected();
    return isConnected;
  }

  Future<String> getLocationDetails() async {
    String error;
    try {
      LocationData location = await _locationService.getCurrentLocation();
      initialCityName = await _locationService.getCityNameFromLatLon(location.latitude, location.longitude);
      initialAreaCode = await _locationService.getZipFromLatLon(location.latitude, location.longitude);
      notifyListeners();
    } catch (e) {
      error = "Location Error";
    }
    return error;
  }

  @override
  void onData(WebblenUser data) {
    if (data != null) {
      user = data;
      notifyListeners();
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      String uid = await _authService.getCurrentUserID();
      var res = await _userDataService.getWebblenUserByID(uid);
      if (res is String) {
        yield null;
      } else {
        yield res;
      }
    }
  }

///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }

}
