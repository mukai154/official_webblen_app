import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/user_pages/setup_page.dart';

import 'auth_pages/login_page.dart';
import 'home_page.dart';
import 'root_page.dart';
import 'styles/flat_colors.dart';

void main() => runApp(new WebblenApp());

class WebblenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Webblen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: FlatColors.webblenRed,
        accentColor: FlatColors.darkGray,
      ),
      home: RootPage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(),
        '/root': (BuildContext context) => new RootPage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/setup': (BuildContext context) => new SetupPage(),
      },
    );
  }
}
