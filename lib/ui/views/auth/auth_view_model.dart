import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  ThemeService? themeService = locator<ThemeService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  WebblenBaseViewModel? _webblenBaseViewModel = locator<WebblenBaseViewModel>();
  bool signInViaPhone = true;
  String? phoneNo;
  late String phoneVerificationID;

  ///Sign Up Via Email
  Future signInWithEmail({required email, required password}) async {
    setBusy(true);

    var result = await _authService!.signInWithEmail(
      email: email,
      password: password,
    );

    setBusy(false);

    if (result is bool) {
      if (result) {
        navigateToHomePage();
      } else {
        _snackbarService!.showSnackbar(
          title: 'Login Error',
          message: "There Was an Issue Logging In. Please Try Again",
          duration: Duration(seconds: 5),
        );
      }
    } else {
      _snackbarService!.showSnackbar(
        title: 'Login Error',
        message: result,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<bool> sendSMSCode({required phoneNo}) async {
    //Phone Timeout & Verifcation

    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      phoneVerificationID = verId;
      notifyListeners();
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int? forceCodeResend]) {
      phoneVerificationID = verId;
      notifyListeners();
    };

    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException exception) {
      return _snackbarService!.showSnackbar(
        title: 'Phone Login Error',
        message: exception.message!,
        duration: Duration(seconds: 5),
      );
    };

    final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async {
      // ANDROID ONLY!
      // Sign the user in (or link) with the auto-generated credential
      if (Platform.isAndroid) {
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    };

    if (phoneNo != null && phoneNo.isNotEmpty && phoneNo.length >= 10) {
      //SEND SMS CODE FOR VERIFICATION
      String? error = await _authService!.verifyPhoneNum(
        phoneNo: phoneNo,
        autoRetrievalTimeout: autoRetrieve,
        smsCodeSent: smsCodeSent,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
      );

      if (error != null) {
        _snackbarService!.showSnackbar(
          title: 'Phone Login Error',
          message: error,
          duration: Duration(seconds: 5),
        );
        return false;
      } else {
        return true;
      }
    } else {
      setBusy(false);

      _snackbarService!.showSnackbar(
        title: 'Phone Login Error',
        message: "Invalid Phone Number",
        duration: Duration(seconds: 5),
      );

      return false;
    }
  }

  signInWithSMSCode({required BuildContext context, required String smsCode}) async {
    Navigator.of(context).pop();

    setBusy(true);

    var res = await _authService!.signInWithSMSCode(verificationID: phoneVerificationID, smsCode: smsCode);

    if (res is String) {
      setBusy(false);
      _snackbarService!.showSnackbar(
        title: 'Phone Login Error',
        message: res,
        duration: Duration(seconds: 5),
      );
    } else {
      navigateToHomePage();
    }
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

  loginWithFacebook() async {
    setBusy(true);

    var res = await _authService!.loginWithFacebook();

    setBusy(false);

    if (res is String) {
      _snackbarService!.showSnackbar(
        title: 'Facebook Sign In Error',
        message: res,
        duration: Duration(seconds: 5),
      );
    } else {
      print(res);
      navigateToHomePage();
    }
  }

  ///NAVIGATION
  navigateToHomePage() {
    if (_webblenBaseViewModel!.initialised) {
      _webblenBaseViewModel!.initialize();
    }
    _navigationService!.pushNamedAndRemoveUntil(Routes.WebblenBaseViewRoute);
  }
}
