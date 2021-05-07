import 'package:stacked/stacked.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class RootViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  ThemeService _themeService = locator<ThemeService>();

  ///CHECKS IF USER IS LOGGED IN
  Future checkAuthState() async {
    bool isLoggedIn = await _authService.isLoggedIn();
    print(isLoggedIn);
    if (isLoggedIn) {
      bool completedSignIn = await _authService.completeUserSignIn();
      if (!completedSignIn) {
        navigateToSignIn();
      } else {
        _customNavigationService.navigateToBase();
      }
    } else {
      navigateToSignIn();
    }
  }

  navigateToSignIn() {
    _themeService.setThemeMode(ThemeManagerMode.light);
    notifyListeners();
    _customNavigationService.navigateToAuthView();
  }
}
