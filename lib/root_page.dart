import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webblen/models/webblen_user.dart';

import 'firebase/data/webblen_user_data.dart';
import 'pages/auth/splash_page.dart';
import 'pages/home/home_page.dart';

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((val) {
      authStatus = val != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return Container(color: Colors.white);
      case AuthStatus.notSignedIn:
        return SplashPage();
      case AuthStatus.signedIn:
        FirebaseUser user = Provider.of<FirebaseUser>(context);
        return user == null
            ? Container(color: Colors.white)
            : StreamProvider<WebblenUser>.value(
                value: WebblenUserData().streamCurrentUser(user.uid),
                child: HomePage(
                  currentUserUID: user.uid,
                ),
              );
    }
  }
}
