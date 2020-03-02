import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webblen/models/webblen_user.dart';

import 'firebase/data/webblen_user_data.dart';
import 'pages/auth/splash_page.dart';
import 'pages/home/home_page.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    bool isLoggedIn = user != null;
    if (isLoggedIn) {
      return StreamProvider<WebblenUser>.value(
        value: WebblenUserData().streamCurrentUser(user.uid),
        child: HomePage(
          currentUserUID: user.uid,
        ),
      );
    } else {
      return SplashPage();
    }
  }
}
