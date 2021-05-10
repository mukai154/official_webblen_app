import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class AuthViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  ThemeService? _themeService = locator<ThemeService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  UserDataService _userDataService = locator<UserDataService>();

  ///HELPERS
  //final phoneMaskController = MaskedTextController(mask: '000-000-0000');
  final smsController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool signInViaPhone = true;
  String? phoneNo;
  String? phoneVerificationID;
  int? forceResendToken;

  ///Sign Up Via Email
  Future signInWithEmail({required email, required password}) async {
    setBusy(true);

    bool signedIn = await _authService.signInWithEmail(email: email, password: password);

    if (signedIn) {
      String? uid = await _authService.getCurrentUserID();
      if (uid != null) {
        await signUserIn(uid);
      }
    } else {
      setBusy(false);
    }
  }

  Future<bool> sendSMSCode({required String phoneNo}) async {
    //Phone Timeout & Verifcation

    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      phoneVerificationID = verId;
      notifyListeners();
    };

    final PhoneCodeSent smsCodeSent = (String verID, [int? token]) {
      phoneVerificationID = verID;
      forceResendToken = token;
      notifyListeners();
    };

    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException exception) {
      return _customDialogService.showErrorDialog(description: exception.message!);
    };

    final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async {
      // ANDROID ONLY!
      // Sign the user in (or link) with the auto-generated credential
      if (Platform.isAndroid) {
        await _authService.signInWithPhoneCredential(credential: credential);
        navigateToHomePage();
      }
    };

    if (phoneNo != null && phoneNo.isNotEmpty && phoneNo.length >= 10) {
      //SEND SMS CODE FOR VERIFICATION
      bool verifiedPhoneNumber = await _authService.verifyPhoneNum(
        phoneNo: phoneNo,
        autoRetrievalTimeout: autoRetrieve,
        smsCodeSent: smsCodeSent,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        forceResendToken: forceResendToken ?? 0,
      );

      if (verifiedPhoneNumber) {
        return true;
      }
    }
    return false;
  }

  signInWithSMSCode({required BuildContext context, required String smsCode}) async {
    Navigator.of(context).pop();

    setBusy(true);

    bool signedIn = await _authService.signInWithSMSCode(verificationID: phoneVerificationID!, smsCode: smsCode);

    if (signedIn) {
      navigateToHomePage();
    }
    setBusy(false);
  }

  setPhoneNo(String val) {
    phoneNo = val.replaceAll("-", "");
    notifyListeners();
  }

  togglePhoneEmailAuth() {
    if (signInViaPhone) {
      signInViaPhone = false;
    } else {
      signInViaPhone = true;
    }
    notifyListeners();
  }

  signInWithApple() async {
    setBusy(true);

    bool signedIn = await _authService.signInWithApple();

    if (signedIn) {
      String? uid = await _authService.getCurrentUserID();
      if (uid != null) {
        await signUserIn(uid);
      }
    } else {
      setBusy(false);
    }
  }

  signInWithGoogle() async {
    setBusy(true);

    bool signedIn = await _authService.signInWithGoogle();

    if (signedIn) {
      String? uid = await _authService.getCurrentUserID();
      if (uid != null) {
        await signUserIn(uid);
      }
    } else {
      setBusy(false);
    }
  }

  signInWithFacebook() async {
    setBusy(true);

    bool signedIn = await _authService.signInWithFacebook();

    if (signedIn) {
      String? uid = await _authService.getCurrentUserID();
      if (uid != null) {
        await signUserIn(uid);
      }
    } else {
      setBusy(false);
    }
  }

  signUserIn(String uid) async {
    WebblenUser user = WebblenUser();
    bool? userExists = await _userDataService.checkIfUserExists(uid);
    if (userExists != null && !userExists) {
      user = WebblenUser().generateNewUser(uid);
      await _userDataService.createWebblenUser(user);
    } else {
      user = await _userDataService.getWebblenUserByID(uid);
    }
    _reactiveUserService.updateUserLoggedIn(true);
    _reactiveUserService.updateUser(user);
    notifyListeners();
    navigateToHomePage();
  }

  ///NAVIGATION
  navigateToHomePage() {
    _customNavigationService.navigateToBase();
  }
}
