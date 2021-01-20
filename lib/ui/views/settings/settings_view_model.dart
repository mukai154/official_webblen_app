import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/services/auth/auth_service.dart';

class SettingsViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  ThemeService _themeService = locator<ThemeService>();

  toggleDarkMode() {
    if (_themeService.selectedThemeMode == ThemeManagerMode.light) {
      _themeService.setThemeMode(ThemeManagerMode.dark);
    } else {
      _themeService.setThemeMode(ThemeManagerMode.light);
    }
  }

  bool isDarkMode() {
    if (_themeService.selectedThemeMode == ThemeManagerMode.light) {
      return false;
    } else {
      return true;
    }
  }

  signOut(BuildContext context) async {
    String action = await showModalActionSheet(
      message: "Are You Sure You Want to Log Out?",
      context: context,
      actions: [
        SheetAction(label: "Log Out", key: 'logout', isDestructiveAction: true),
      ],
    );
    if (action == "logout") {
      await _authService.signOut();
      if (_themeService.selectedThemeMode != ThemeManagerMode.light) {
        _themeService.setThemeMode(ThemeManagerMode.light);
      }
      _navigationService.pushNamedAndRemoveUntil(Routes.RootViewRoute);
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
