import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/app/theme_config.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/ui/bottom_sheets/setup_bottom_sheet_ui.dart';

import 'models/webblen_user.dart';

void main() async {
  // Register all the models and services before the app starts
  await Future.delayed(Duration(seconds: 2));
  await ThemeManager.initialise();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  setupBottomSheetUI();
  setupSnackBarUi();

  //Get User Instance if Previously Logged In
  await setupAuthListener();

  runApp(WebblenApp());
}

Future<void> setupAuthListener() async {
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  UserDataService _userDataService = locator<UserDataService>();
  FirebaseAuth.instance.authStateChanges().listen((event) async {
    if (event != null) {
      print(event.uid);
      _reactiveUserService.updateUserLoggedIn(true);
      WebblenUser user = await _userDataService.getWebblenUserByID(event.uid);
      _reactiveUserService.updateUser(user);
    }
  });
}

void setupSnackBarUi() {
  final service = locator<SnackbarService>();
  service.registerSnackbarConfig(
    SnackbarConfig(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      mainButtonTextColor: Colors.black,
    ),
  );
}

class WebblenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      lightTheme: regularTheme,
      darkTheme: darkTheme,
      builder: (context, regularTheme, darkTheme, themeMode) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Webblen',
        theme: regularTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        initialRoute: Routes.RootViewRoute,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
      ),
    );
  }
}
