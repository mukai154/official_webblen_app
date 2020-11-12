import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webblen/home_page.dart';
import 'package:webblen/pages/auth_pages/login_page.dart';
import 'package:webblen/pages/onboarding/onboarding_path_select_page.dart';
import 'package:webblen/root_page.dart';
import 'package:webblen/styles/flat_colors.dart';

import 'pages/onboarding/onboarding_complete_page.dart';
import 'pages/user_pages/setup_page.dart';

void main() {
  runApp(WebblenApp());
}

class WebblenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(
              providers: [
                StreamProvider<User>.value(value: FirebaseAuth.instance.authStateChanges()),
              ],
              child: MaterialApp(
                title: 'Webblen',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  brightness: Brightness.light,
                  primaryColor: FlatColors.webblenRed,
                  accentColor: FlatColors.darkGray,
                  textTheme: Theme.of(context).textTheme.apply(
                        fontFamily: "Helvetica Neue",
                      ),
                ),
                home: RootPage(),
                routes: <String, WidgetBuilder>{
                  '/root': (BuildContext context) => RootPage(),
                  '/login': (BuildContext context) => LoginPage(),
                  '/setup': (BuildContext context) => SetupPage(),
                  '/onboarding': (BuildContext context) => OnboardingPathSelectPage(),
                  '/home': (BuildContext context) => HomePage(),
                  '/onboarding_complete': (BuildContext context) => OnboardingCompletePage(),
                },
              ),
            );
          }
          return Container(color: Colors.white);
        });
  }
}
