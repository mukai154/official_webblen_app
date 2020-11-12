import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/services/api/facebook_graph_api.dart';

class BaseAuth {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = result.user;
    return user != null ? user.uid : null;
  }

  Future<String> createUser(String email, String password) async {
    UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = result.user;
    return user.uid;
  }

  Future<String> getCurrentUserID() async {
    User user = firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  Future<String> signOut() async {
    await firebaseAuth.signOut();
    User user = firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  Future<String> linkFacebookAccount(LoginResult result) async {
    String error;
    bool hasFBAccountConnected = false;
    User user = firebaseAuth.currentUser;
    user.providerData.forEach((userInfo) async {
      if (userInfo.providerId == "facebook.com") {
        hasFBAccountConnected = true;
        String fbID = await FacebookGraphAPI().getUserID(result.accessToken.token);
        if (userInfo.uid == fbID) {
          await WebblenUserData().setFBAccessToken(user.uid, result.accessToken.token);
        } else {
          error = "This Account is Already Associated with a FB Account";
        }
      }
    });
    if (!hasFBAccountConnected) {
      final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken.token);
      await user.linkWithCredential(credential).then((res) {
        WebblenUserData().setFBAccessToken(user.uid, result.accessToken.token);
      }).catchError((e) {
        error = e.code;
      });
    }
    return error;
  }

  Future<String> linkYoutubeAccount(GoogleSignInAuthentication googleAuth) async {
    String error;
    bool hasGoogleAccountConnected = false;
    User user = firebaseAuth.currentUser;
    user.providerData.forEach((userInfo) async {
      print(userInfo);
      if (userInfo.providerId == "google.com") {
        hasGoogleAccountConnected = true;
        // String fbID = await FacebookGraphAPI().getUserID(result.accessToken.token);
        // if (userInfo.uid == fbID) {
        //   await WebblenUserData().setFBAccessToken(user.uid, result.accessToken.token);
        // } else {
        //   error = "This Account is Already Associated with a FB Account";
        // }
      }
    });
    if (!hasGoogleAccountConnected) {
      final AuthCredential credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      await user.linkWithCredential(credential).then((res) {
        WebblenUserData().setGoogleAccessTokenAndID(user.uid, googleAuth.accessToken, googleAuth.idToken);
      }).catchError((e) {
        error = e.code;
      });
    }
    return error;
  }
}
