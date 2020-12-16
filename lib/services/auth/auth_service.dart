import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //AUTH STATE
  Future<bool> isLoggedIn() async {
    User user = firebaseAuth.currentUser;
    return user != null;
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

  //SIGN IN & REGISTRATION
  Future signUpWithEmail({@required String email, @required String password}) async {
    try {
      UserCredential credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      credential.user.sendEmailVerification();
      return credential.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future signInWithEmail({@required String email, @required String password}) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        if (credential.user.emailVerified) {
          return true;
        } else {
          return "Email Confirmation Required";
        }
      }
    } catch (e) {
      return e.message;
    }
  }
}
