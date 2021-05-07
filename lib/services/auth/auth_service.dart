import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class AuthService {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  UserDataService _userDataService = locator<UserDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///AUTH STATE
  Future<bool> isLoggedIn() async {
    await Future.delayed(Duration(milliseconds: 500));
    User? user = firebaseAuth.currentUser;
    return user != null;
  }

  String? getCurrentUserID() {
    User? user = firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  Future<String?> signOut() async {
    await firebaseAuth.signOut();
    User? user = firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  ///SIGN IN & REGISTRATION
  //Email
  Future<bool> signInWithEmail({required String email, required String password}) async {
    bool signedIn = false;
    await firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((value) {
      signedIn = true;
    }).catchError((error) {
      _customDialogService.showErrorDialog(description: error.message);
    });
    return signedIn;
  }

  //Phone
  Future<bool> verifyPhoneNum({
    required String phoneNo,
    required PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout,
    required PhoneCodeSent smsCodeSent,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
  }) async {
    bool verified = true;
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: phoneNo,
      codeAutoRetrievalTimeout: autoRetrievalTimeout,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
    )
        .catchError((e) {
      _customDialogService.showErrorDialog(description: e.message);
      verified = false;
    });
    return verified;
  }

  Future<bool> signInWithSMSCode({required String verificationID, required String smsCode}) async {
    bool signedIn = false;
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: smsCode,
    );

    await FirebaseAuth.instance.signInWithCredential(credential).then((credential) async {
      bool? userExists = await _userDataService.checkIfUserExists(credential.user!.uid);
      if (!userExists!) {
        WebblenUser user = WebblenUser().generateNewUser(credential.user!.uid);
        await _userDataService.createWebblenUser(user);
      }
      signedIn = true;
    }).catchError((e) {
      _customDialogService.showErrorDialog(description: e.message);
    });

    return signedIn;
  }

  Future<bool> signInWithPhoneCredential({required PhoneAuthCredential credential}) async {
    bool signedIn = false;
    await FirebaseAuth.instance.signInWithCredential(credential).then((credential) async {
      bool? userExists = await _userDataService.checkIfUserExists(credential.user!.uid);
      if (!userExists!) {
        WebblenUser user = WebblenUser().generateNewUser(credential.user!.uid);
        await _userDataService.createWebblenUser(user);
      }
      signedIn = true;
    }).catchError((e) {
      _customDialogService.showErrorDialog(description: e.message);
    });
    return signedIn;
  }

  Future<String?> sendSMSCode({
    required String phoneNo,
    required PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout,
    required PhoneCodeSent smsCodeSent,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
  }) async {
    String? error;
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: phoneNo,
      codeAutoRetrievalTimeout: autoRetrievalTimeout,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
    )
        .catchError((e) {
      error = e.message;
    });
    return error;
  }

  Future<bool> signInWithPhone({required String verificationID, required String smsCode}) async {
    bool signedIn = false;
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: smsCode,
    );

    await FirebaseAuth.instance.signInWithCredential(credential).then((credential) async {
      bool? userExists = await _userDataService.checkIfUserExists(credential.user!.uid);
      if (!userExists!) {
        WebblenUser user = WebblenUser().generateNewUser(credential.user!.uid);
        await _userDataService.createWebblenUser(user);
      }
      signedIn = true;
    }).catchError((e) {
      _customDialogService.showErrorDialog(description: e.message);
    });
    return signedIn;
  }

  //Apple
  Future<bool> signInWithApple() async {
    bool signedIn = false;
    await FirebaseAuthOAuth().openSignInFlow("apple.com", ["email"]).then((user) async {
      print('apple sign in with user: ${user!.uid}');
      print(user.email);
      bool? userExists = await _userDataService.checkIfUserExists(user.uid);
      if (!userExists!) {
        WebblenUser webblenUser = WebblenUser().generateNewUser(user.uid);
        await _userDataService.createWebblenUser(webblenUser);
      }
      signedIn = true;
    }).catchError((error) {
      _customDialogService.showErrorDialog(description: error.message);
      signedIn = false;
    });
    return signedIn;
  }

  //Google
  Future<bool> signInWithGoogle() async {
    bool signedIn = false;
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    await _googleSignIn.signIn().then((googleAccount) async {
      await googleAccount!.authentication.then((googleAuth) async {
        AuthCredential credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
        await FirebaseAuth.instance.signInWithCredential(credential).then((val) async {
          bool? userExists = await _userDataService.checkIfUserExists(val.user!.uid);
          if (!userExists!) {
            WebblenUser user = WebblenUser().generateNewUser(val.user!.uid);
            user.googleIDToken = googleAuth.idToken;
            user.googleAccessToken = googleAuth.accessToken;
            await _userDataService.createWebblenUser(user);
          }
          signedIn = true;
        }).catchError((e) {
          _customDialogService.showErrorDialog(description: e.message);
        });
      });
    }).catchError((e) {
      print(e.message);
      //_customDialogService.showErrorDialog(description: e.message);
    });
    return signedIn;
  }

  //Facebook
  Future<bool> signInWithFacebook() async {
    bool signedIn = false;
    final FacebookAuth fbAuth = FacebookAuth.instance;
    final LoginResult result = await fbAuth.login(permissions: ['email']);
    switch (result.status) {
      case LoginStatus.success:
        final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        await FirebaseAuth.instance.signInWithCredential(credential).then((val) async {
          bool? userExists = await _userDataService.checkIfUserExists(val.user!.uid);
          if (!userExists!) {
            WebblenUser user = WebblenUser().generateNewUser(val.user!.uid);
            user.fbAccessToken = result.accessToken!.token;
            await _userDataService.createWebblenUser(user);
          }
          signedIn = true;
        }).catchError((e) {
          _customDialogService.showErrorDialog(description: e.message);
        });
        break;
      case LoginStatus.cancelled:
        _customDialogService.showErrorDialog(description: "Cancelled Facebook Sign In");
        break;
      case LoginStatus.failed:
        _customDialogService.showErrorDialog(description: "There was an Issue Signing Into Facebook");
        break;
      case LoginStatus.operationInProgress:
        // TODO: Handle this case.
        break;
    }
    return signedIn;
  }

  Future<bool> completeUserSignIn() async {
    bool completedSignIn = true;
    String? uid = await getCurrentUserID();
    print(uid);
    if (uid != null) {
      bool? userExists = await _userDataService.checkIfUserExists(uid);
      if (userExists == null) {
        _customDialogService.showErrorDialog(description: "Unknown error logging in. Please try again.");
        return false;
      } else if (userExists) {
        WebblenUser user = await _userDataService.getWebblenUserByID(uid);
        _reactiveUserService.updateUser(user);
        _reactiveUserService.updateUserLoggedIn(true);

        ///CHECK IF USER ONBOARDED
        if (user.onboarded == null || !user.onboarded!) {
          print('onboard');
        } else {
          _customNavigationService.navigateToBase();
        }
      } else {
        ///CREATE NEW USER
        WebblenUser user = WebblenUser().generateNewUser(uid);
        bool createdUser = await _userDataService.createWebblenUser(user);
        if (createdUser) {
          _reactiveUserService.updateUser(user);
          _reactiveUserService.updateUserLoggedIn(true);
          print('go onboard');
        } else {
          _customDialogService.showErrorDialog(description: "Unknown error logging in. Please try again.");
          return false;
        }
      }
    }

    return completedSignIn;
  }
}
