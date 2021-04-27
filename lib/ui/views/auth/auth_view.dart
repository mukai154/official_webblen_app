import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/auth/auth_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/apple_auth_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/buttons/email_auth_button.dart';
import 'package:webblen/ui/widgets/common/buttons/fb_auth_button.dart';
import 'package:webblen/ui/widgets/common/buttons/google_auth_button.dart';
import 'package:webblen/ui/widgets/common/buttons/phone_auth_button.dart';
import 'package:webblen/ui/widgets/common/text_field/phone_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/single_line_text_field.dart';
import 'package:webblen/utils/url_handler.dart';

class AuthView extends StatelessWidget {
  final phoneMaskController = MaskedTextController(mask: '000-000-0000');
  final smsController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Widget orTextLabel() {
    return Text(
      'or sign in with',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget authButtons(AuthViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FacebookAuthButton(
          action: () => model.loginWithFacebook(),
        ),
        Platform.isIOS
            ? AppleAuthButton(
                action: null,
              )
            : Container(),
        GoogleAuthButton(
          action: null,
        ),
        model.signInViaPhone
            ? EmailAuthButton(
                action: () => model.togglePhoneEmailAuth(),
              )
            : PhoneAuthButton(
                action: () => model.togglePhoneEmailAuth(),
              )
      ],
    );
  }

  Widget serviceAgreement() {
    return Container(
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
              recognizer: TapGestureRecognizer()..onTap = () => UrlHandler().launchInWebViewOrVC("https://webblen.io/terms-and-conditions"),
            ),
            TextSpan(
              text: 'and ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Privacy Policy. ',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()..onTap = () => UrlHandler().launchInWebViewOrVC("https://webblen.io/privacy-policy"),
            ),
          ],
        ),
      ),
    );
  }

  displayBottomActionSheet(BuildContext context, AuthViewModel model) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'Enter SMS Code',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16),
              SingleLineTextField(
                controller: smsController,
                hintText: 'SMS Code',
                textLimit: null,
                isPassword: false,
              ),
              SizedBox(height: 24),
              CustomButton(
                elevation: 1,
                text: 'Submit',
                textColor: Colors.black,
                backgroundColor: Colors.white,
                isBusy: model.isBusy,
                height: 50,
                width: screenWidth(context),
                onPressed: () => model.signInWithSMSCode(
                  context: context,
                  smsCode: smsController.text,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  sendSMSCode(BuildContext context, AuthViewModel model) async {
    bool receivedVerificationID = await model.sendSMSCode(phoneNo: model.phoneNo);
    if (receivedVerificationID) {
      displayBottomActionSheet(context, model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 200,
                          child: Image.asset('assets/images/webblen_logo_text.jpg'),
                        ),
                        verticalSpaceLarge,
                        model.signInViaPhone
                            ? PhoneTextField(
                                controller: phoneMaskController,
                                hintText: "701-120-3000",
                                onChanged: (phoneNo) => model.setPhoneNo(phoneNo),
                              )
                            : Column(
                                children: [
                                  SingleLineTextField(
                                    controller: emailController,
                                    hintText: "Email Address",
                                    textLimit: null,
                                    isPassword: false,
                                  ),
                                  verticalSpaceSmall,
                                  SingleLineTextField(
                                    controller: passwordController,
                                    hintText: "Password",
                                    textLimit: null,
                                    isPassword: true,
                                  ),
                                ],
                              ),
                        verticalSpaceMedium,
                        CustomButton(
                          elevation: 1,
                          text: model.signInViaPhone ? 'Send SMS Code' : 'Login',
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          isBusy: model.isBusy,
                          height: 50,
                          width: screenWidth(context),
                          onPressed: model.signInViaPhone
                              ? () => sendSMSCode(context, model)
                              : () => model.signInWithEmail(email: emailController.text, password: passwordController.text),
                        ),
                        verticalSpaceMedium,
                        orTextLabel(),
                        verticalSpaceSmall,
                        authButtons(model),
                      ],
                    ),
                  ),
                  verticalSpaceLarge,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: serviceAgreement(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
