import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class RootViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  UserDataService _userDataService = locator<UserDataService>();
  NavigationService _navigationService = locator<NavigationService>();

  initialize() async {
    checkAuthState();
  }

  ///CHECKS IF USER IS LOGGED IN
  Future checkAuthState() async {
    bool isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      ///CHECK IF USER HAS CREATED PROFILE
      String uid = await _authService.getCurrentUserID();
      bool userExists = await _userDataService.checkIfUserExists(uid);
      if (userExists) {
        _navigationService.replaceWith(Routes.HomeNavViewRoute);
      } else {
        //_navigationService.replaceWith(Routes.OnboardingViewRoute);
      }
    } else {
      _navigationService.replaceWith(Routes.AuthViewRoute);
    }
  }
}
