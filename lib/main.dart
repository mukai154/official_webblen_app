import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:webblen/home_page.dart';
import 'package:webblen/pages/auth_pages/login_page.dart';
import 'package:webblen/pages/user_pages/setup_page.dart';
import 'package:webblen/root_page.dart';
import 'package:webblen/services/in_app_purchases/in_app_purchases.dart';
import 'package:webblen/styles/flat_colors.dart';

void main() {
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(WebblenApp());
}

class WebblenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: FirebaseAuth.instance.onAuthStateChanged),
        StreamProvider<List<PurchaseDetails>>.value(value: InAppPurchaseService().streamPurchases()),
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
          '/home': (BuildContext context) => HomePage(),
          '/root': (BuildContext context) => RootPage(),
          '/login': (BuildContext context) => LoginPage(),
          '/setup': (BuildContext context) => SetupPage(),
        },
      ),
    );
  }
}
