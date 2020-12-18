import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/user_data_service.dart';

class ProfileViewModel extends StreamViewModel<WebblenUser> {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  ThemeService themeService = locator<ThemeService>();
  UserDataService _userDataService = locator<UserDataService>();

  WebblenUser user;

  initialize() async {
    setBusy(true);
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToSettingsPage() {
    _navigationService.navigateTo(Routes.SettingsViewRoute, arguments: {'data': 'example'});
  }

  @override
  void onData(WebblenUser data) {
    if (data != null) {
      user = data;
      notifyListeners();
      if (isBusy) {
        setBusy(false);
      }
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
}
