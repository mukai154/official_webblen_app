import 'package:injectable/injectable.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/utils/network_status.dart';

@singleton
class WebblenBaseViewModel extends StreamViewModel<WebblenUser> {
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
  InitErrorStatus initErrorStatus = InitErrorStatus.none;
  String initialCityName;
  String initialAreaCode;

  ///CURRENT USER
  String uid;
  WebblenUser user;

  ///TAB BAR STATE
  int _navBarIndex = 0;

  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    notifyListeners();
  }

  ///STREAM USER DATA
  @override
  void onData(WebblenUser data) {
    if (data != null) {
      if (user != data) {
        user = data;
        notifyListeners();
        setBusy(false);
      }
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      if (uid == null) {
        yield null;
      }
      await Future.delayed(Duration(seconds: 1));
      WebblenUser user = await _userDataService.getWebblenUserByID(uid);
      yield user;
    }
  }

  ///INITIALIZE DATA
  initialize() async {
    setBusy(true);
    uid = await _authService.getCurrentUserID();
    notifyListeners();

    //check network status
    bool connectedToNetwork = await isConnectedToNetwork();
    if (!connectedToNetwork) {
      initErrorStatus = InitErrorStatus.network;
      notifyListeners();
      _snackbarService.showSnackbar(
        title: 'Network Error',
        message: "There Was an Issue Connecting to the Internet",
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
      _snackbarService.showSnackbar(
        title: 'Location Error',
        message: "There Was an Issue Getting Your Location",
        duration: Duration(seconds: 5),
      );
      setBusy(false);
      return;
    }

    //if there are no errors, check for dynamic links
    initErrorStatus = InitErrorStatus.none;
    await _dynamicLinkService.handleDynamicLinks();
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
    try {
      LocationData location = await _locationService.getCurrentLocation();
      initialCityName = await _locationService.getCityNameFromLatLon(location.latitude, location.longitude);
      initialAreaCode = await _locationService.getZipFromLatLon(location.latitude, location.longitude);
      notifyListeners();
    } catch (e) {
      return false;
    }
    return true;
  }

  ///BOTTOM SHEETS
  //bottom sheet for new post, stream, or event
  showAddContentOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.addContent,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "new post") {
        navigateToCreatePostPage();
      } else if (res == "new stream") {
        //
      } else if (res == "new event") {
        //
      }
      notifyListeners();
    }
  }

  //bottom sheet for post options
  showPostOptions() async {}

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToCreatePostPage() {
    _navigationService.navigateTo(Routes.CreatePostViewRoute);
  }

// navigateToCreateStreamPage() {
//   _navigationService.navigateTo(Routes.CreateStreamViewRoute);
// }
//
// navigateToCreateEventPage() {
//   _navigationService.navigateTo(Routes.CreateEventViewRoute);
// }

}
