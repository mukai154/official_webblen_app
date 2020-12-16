import 'package:stacked/stacked.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/locator.dart';

class RootViewModel extends BaseViewModel {
  // AuthService _authService = locator<AuthService>();
  // UserDataService _userDataService = locator<UserDataService>();
  // NavigationService _navigationService = locator<NavigationService>();
  ThemeService themeService = locator<ThemeService>();

  ///CHECKS IF USER IS LOGGED IN
  Future checkAuthState() async {
    // bool isLoggedIn = await _authService.isLoggedIn();
    // if (isLoggedIn) {
    //   ///CHECK IF USER HAS CREATED PROFILE
    //   String uid = await _authService.getCurrentUserID();
    //   bool goUserExists = await _userDataService.checkIfUserExists(uid);
    //   if (goUserExists) {
    //     _navigationService.replaceWith(Routes.HomeNavViewRoute);
    //   } else {
    //     _navigationService.replaceWith(Routes.OnboardingViewRoute);
    //   }
    // } else {
    //   _navigationService.replaceWith(Routes.SignInViewRoute);
    // }
  }
}
