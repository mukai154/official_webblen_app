import 'package:stacked/stacked.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/utils/url_handler.dart';

class SettingsViewModel extends BaseViewModel {
  ThemeService _themeService = locator<ThemeService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();

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

  getHelpFAQ() {
    UrlHandler().launchInWebViewOrVC("https://www.webblen.io/faq");
  }

  signOut() async {
    _customBottomSheetService.showLogoutBottomSheet();
  }
}
