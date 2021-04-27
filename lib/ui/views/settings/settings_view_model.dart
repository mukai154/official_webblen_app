import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/services/auth/auth_service.dart';

class SettingsViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  ThemeService? _themeService = locator<ThemeService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();

  toggleDarkMode() {
    if (_themeService!.selectedThemeMode == ThemeManagerMode.light) {
      _themeService!.setThemeMode(ThemeManagerMode.dark);
    } else {
      _themeService!.setThemeMode(ThemeManagerMode.light);
    }
  }

  bool isDarkMode() {
    if (_themeService!.selectedThemeMode == ThemeManagerMode.light) {
      return false;
    } else {
      return true;
    }
  }

  signOut({BuildContext? context}) async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      title: "Log Out",
      description: "Are You Sure You Want to Log Out?",
      mainButtonTitle: "Log Out",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "confirmed") {
        await _authService!.signOut();
        if (_themeService!.selectedThemeMode != ThemeManagerMode.light) {
          _themeService!.setThemeMode(ThemeManagerMode.light);
        }
        //_navigationService.pushNamedAndRemoveUntil(Routes.RootViewRoute);
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
