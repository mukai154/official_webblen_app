import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/user_data_service.dart';

class HomeNavViewModel extends StreamViewModel<WebblenUser> {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();

  WebblenUser user;

  //Tab Bar State
  int _navBarIndex = 0;
  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    notifyListeners();
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

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }

}
