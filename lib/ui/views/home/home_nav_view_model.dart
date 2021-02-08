import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/utils/network_status.dart';

class HomeNavViewModel extends StreamViewModel<WebblenUser> {
  ///SERVICES
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();

  ///INITIAL DATA
  InitErrorStatus initErrorStatus = InitErrorStatus.network;
  String initialCityName;
  String initialAreaCode;

  ///CURRENT USER
  WebblenUser user;

  ///TAB BAR STATE
  int _navBarIndex = 0;
  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    notifyListeners();
  }

  initialize() async {
    setBusy(true);
    isConnectedToNetwork().then((connected) {

      //check network status
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

        //get location data
        getLocationDetails().then((e) async {
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

            //if there are no errors, check for dynamic links
            initErrorStatus = InitErrorStatus.none;
            await _dynamicLinkService.handleDynamicLinks();
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
      setBusy(false);
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
