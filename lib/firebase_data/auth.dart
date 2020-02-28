import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class BaseAuth {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    FirebaseUser user = result.user;
    return user != null ? user.uid : null;
  }

  Future<String> createUser(String email, String password) async {
    AuthResult result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<String> signOut() async {
    await firebaseAuth.signOut();
    FirebaseUser user = await firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }
}
