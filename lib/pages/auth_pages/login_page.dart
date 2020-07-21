import 'dart:async';
import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase_data//auth.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/widgets/auth_buttons/apple_btn.dart';
import 'package:webblen/widgets/auth_buttons/facebook_btn.dart';
import 'package:webblen/widgets/auth_buttons/google_btn.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginScaffoldKey = GlobalKey<ScaffoldState>();
  final authFormKey = GlobalKey<FormState>();

  static final FacebookLogin facebookSignIn = FacebookLogin();
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  bool isLoading = false;
  bool signInWithEmail = false;
  String _email;
  String _password;
  String uid;

  var phoneMaskController = MaskedTextController(mask: '+1 000-000-0000');
  String phoneNo;
  String smsCode;
  String verificationId;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      ShowAlertDialogService().showFormWidget(
        context,
        'Enter SMS Code',
        TextField(
          onChanged: (value) {
            this.smsCode = value;
          },
        ),
        () {
          FirebaseAuth.instance.currentUser().then((user) {
            if (user != null) {
              Navigator.of(context).pop();
              PageTransitionService(context: context).transitionToRootPage();
            } else {
              Navigator.of(context).pop();
              signInWithPhone();
            }
          });
        },
      );
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print(exception.message);
      isLoading = false;
      ShowAlertDialogService().showFailureDialog(context, "Verification Failed", "There was an issue verifying your phone number. Please try again");
      setState(() {});
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: null,
        verificationFailed: veriFailed);
  }

  signInWithPhone() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      if (user != null) {
        PageTransitionService(context: context).transitionToRootPage();
      } else {
        ShowAlertDialogService().showFailureDialog(context, 'Oops!', 'There was an issue signing in.. Please Try Again');
      }
    }).catchError((e) {
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ShowAlertDialogService().showFailureDialog(context, 'Oops!', 'Invalid Verification Code. Please Try Again.');
    });
  }

  setSignInWithEmailStatus() {
    if (signInWithEmail) {
      signInWithEmail = false;
    } else {
      signInWithEmail = true;
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  bool validateAndSave() {
    final form = authFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<Null> validateAndSubmit() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldState scaffold = loginScaffoldKey.currentState;
    if (validateAndSave()) {
      if (signInWithEmail) {
        try {
          uid = await BaseAuth().signIn(_email, _password);
          setState(() {
            isLoading = false;
          });
          PageTransitionService(context: context).transitionToRootPage();
        } catch (e) {
          String error = e.message;
          scaffold.showSnackBar(SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
          setState(() {
            isLoading = false;
          });
        }
      } else {
        verifyPhone();
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldState scaffold = loginScaffoldKey.currentState;
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount == null) {
      scaffold.showSnackBar(SnackBar(
        content: Text("Cancelled Google Login"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
      setState(() {
        isLoading = false;
      });
      return;
    }
    GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      if (user != null) {
        PageTransitionService(context: context).transitionToRootPage();
      } else {
        scaffold.showSnackBar(SnackBar(
          content: Text("There was an Issue Logging Into Google"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void loginWithFacebook() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldState scaffold = loginScaffoldKey.currentState;
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
        FirebaseAuth.instance.signInWithCredential(credential).then((user) {
          if (user != null) {
            PageTransitionService(context: context).transitionToRootPage();
          } else {
            setState(() {
              isLoading = false;
            });
            ShowAlertDialogService().showFailureDialog(context, 'Oops!', 'There was an issue signing in with Facebook. Please Try Again');
          }
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        scaffold.showSnackBar(SnackBar(
          content: Text("Cancelled Facebook Login"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        setState(() {
          isLoading = false;
        });
        break;
      case FacebookLoginStatus.error:
        scaffold.showSnackBar(SnackBar(
          content: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text("There was an Issue Logging Into Facebook"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        setState(() {
          isLoading = false;
        });
        break;
    }
  }

  void loginWithApple() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldState scaffold = loginScaffoldKey.currentState;
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email])
    ]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final AppleIdCredential appleIdCredential = result.credential;
        OAuthProvider oAuthProvider = OAuthProvider(providerId: "apple.com");
        final AuthCredential credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        FirebaseAuth.instance.signInWithCredential(credential).then((user) {
          if (user != null) {
            PageTransitionService(context: context).transitionToRootPage();
          } else {
            setState(() {
              isLoading = false;
            });
            ShowAlertDialogService().showFailureDialog(context, 'Oops!', 'There was an issue signing in with Apple. Please Try Again');
          }
        });
        break;
      case AuthorizationStatus.cancelled:
        scaffold.showSnackBar(SnackBar(
          content: Text("Cancelled Apple Login"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        setState(() {
          isLoading = false;
        });
        break;
      case AuthorizationStatus.error:
        print(result.error);
        scaffold.showSnackBar(SnackBar(
          content: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text("There was an Issue Logging Into Apple"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        setState(() {
          isLoading = false;
        });
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **UI ELEMENTS
    final logo = Image.asset(
      'assets/images/webblen_logo_text.jpg',
      height: 200.0,
      fit: BoxFit.fitHeight,
    );
    final isLoadingProgressBar = CustomLinearProgress(progressBarColor: CustomColors.webblenRed);

    // **EMAIL FIELD
    final emailField = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: TextFormField(
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          validator: (value) => value.isEmpty ? 'Email Cannot be Empty' : null,
          onSaved: (value) => _email = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.email,
              color: Colors.black38,
            ),
            hintText: "Email",
            hintStyle: TextStyle(color: Colors.black38),
            errorStyle: TextStyle(color: Colors.redAccent),
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          ),
        ),
      ),
    );

    // **PHONE FIELD
    final phoneField = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: TextFormField(
          controller: phoneMaskController,
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          keyboardType: TextInputType.number,
          autofocus: false,
          validator: (value) => value.isEmpty ? 'Phone Cannot be Empty' : null,
          onSaved: (value) => phoneNo = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.phone,
              color: Colors.black38,
            ),
            hintText: "Phone Number",
            hintStyle: TextStyle(color: Colors.black38),
            errorStyle: TextStyle(color: Colors.redAccent),
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          ),
        ),
      ),
    );

    // **PASSWORD FIELD
    final passwordField = Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: TextFormField(
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.text,
          obscureText: true,
          autofocus: false,
          validator: (value) => value.isEmpty ? 'Password Cannot be Empty' : null,
          onSaved: (value) => _password = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.lock,
              color: Colors.black38,
            ),
            hintText: "Password",
            hintStyle: TextStyle(color: Colors.black38),
            errorStyle: TextStyle(color: Colors.redAccent),
            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          ),
        ),
      ),
    );

    // **LOGIN BUTTON
    final loginButton = CustomColorButton(
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.85,
      text: signInWithEmail ? 'Sign In' : 'Send SMS Code',
      textColor: Colors.black,
      backgroundColor: Colors.white,
      onPressed: () => validateAndSubmit(),
    );

    // **FACEBOOK BUTTON
    final facebookButton = FacebookBtn(action: loginWithFacebook);

    // **APPLE BUTTON
    final appleButton = AppleBtn(action: loginWithApple);

    // **GOOGLE BUTTON
    final googleButton = GoogleBtn(action: loginWithGoogle);

    //**EMAIL/PHONE BUTTON
    final signInWithEmailButton = CustomColorIconButton(
      icon: Icon(FontAwesomeIcons.envelope, color: Colors.black, size: 18.0),
      text: "Sign in With Email",
      textColor: Colors.black,
      backgroundColor: Colors.white,
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.85,
      onPressed: () => setSignInWithEmailStatus(),
    );

    final signInWithPhoneButton = CustomColorIconButton(
      icon: Icon(FontAwesomeIcons.mobileAlt, color: Colors.black, size: 18.0),
      text: "Sign in With Phone",
      textColor: Colors.black,
      backgroundColor: Colors.white,
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.85,
      onPressed: () => setSignInWithEmailStatus(),
    );

    final orTextLabel = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
        ),
        child: CustomText(
          context: context,
          text: 'or',
          textColor: CustomColors.londonSquare,
          textAlign: TextAlign.left,
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    final authForm = Form(
      key: authFormKey,
      child: Column(
        children: <Widget>[
          emailField,
          passwordField,
          loginButton,
        ],
      ),
    );

    final phoneAuthForm = Form(
      key: authFormKey,
      child: Column(
        children: <Widget>[
          phoneField,
          loginButton,
        ],
      ),
    );

    final serviceAgreement = Container(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'By Registering, You agree to the ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Terms and Conditions ',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () => OpenUrl().launchInWebViewOrVC(context, OpenUrl().launchInWebViewOrVC(context, 'https://webblen.io/terms-and-conditions')),
            ),
            TextSpan(
              text: 'and ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Privacy Policy. ',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () => OpenUrl().launchInWebViewOrVC(context, OpenUrl().launchInWebViewOrVC(context, 'https://webblen.io/privacy-policy')),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      key: loginScaffoldKey,
      body: Theme(
        data: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.white,
          cursorColor: Colors.white,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      isLoading ? isLoadingProgressBar : Container(),
                      SizedBox(height: 32.0),
                      logo,
                      signInWithEmail ? authForm : phoneAuthForm,
                      orTextLabel,
                      facebookButton,
                      Platform.isIOS ? appleButton : Container(),
                      googleButton,
                      signInWithEmail ? signInWithPhoneButton : signInWithEmailButton,
                      SizedBox(height: 16.0),
                      serviceAgreement,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
