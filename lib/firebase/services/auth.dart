import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

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
    FirebaseUser user = result.user;
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
}
