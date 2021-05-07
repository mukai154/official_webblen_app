import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
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
  const AuthView({Key? key}) : super(key: key);

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
          action: () => model.signInWithFacebook(),
        ),
        AppleAuthButton(
          action: () => model.signInWithApple(),
        ),
        GoogleAuthButton(
          action: () => model.signInWithGoogle(),
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

  Widget serviceAgreement(BuildContext context) {
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
              mouseCursor: MaterialStateMouseCursor.clickable,
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()..onTap = () => UrlHandler().launchInWebViewOrVC("https://webblen.io/terms-and-conditions"),
            ),
            TextSpan(
              text: 'and ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Privacy Policy. ',
              mouseCursor: MaterialStateMouseCursor.clickable,
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
                controller: model.smsController,
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
                  smsCode: model.smsController.text,
                ),
                textSize: 14,
              ),
            ],
          ),
        );
      },
    );
  }

  sendSMSCode(BuildContext context, AuthViewModel model) async {
    bool receivedConfirmationResult = await model.sendSMSCode(phoneNo: model.phoneNo);
    if (receivedConfirmationResult) {
      displayBottomActionSheet(context, model);
    }
  }

  Widget authForm(BuildContext context, AuthViewModel model) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 200,
          child: Image.asset(
            'assets/images/webblen_logo_text.jpg',
            filterQuality: FilterQuality.medium,
          ),
        ),
        verticalSpaceMedium,
        model.signInViaPhone
            ? _PhoneNumberField(
                sendSMSCode: () => sendSMSCode(context, model),
              )
            : SingleLineTextField(
                controller: model.emailController,
                hintText: "Email Address",
                textLimit: null,
                isPassword: false,
                onFieldSubmitted: () => model.signInWithEmail(email: model.emailController.text, password: model.passwordController.text),
              ),
        verticalSpaceSmall,
        model.signInViaPhone
            ? Container()
            : SingleLineTextField(
                controller: model.passwordController,
                hintText: "Password",
                textLimit: null,
                isPassword: true,
                onFieldSubmitted: () => model.signInWithEmail(email: model.emailController.text, password: model.passwordController.text),
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
              : () => model.signInWithEmail(email: model.emailController.text, password: model.passwordController.text),
          textSize: 14,
        ),
        verticalSpaceMedium,
        orTextLabel(),
        verticalSpaceSmall,
        authButtons(model),
        verticalSpaceLarge,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: serviceAgreement(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              constraints: BoxConstraints(
                maxWidth: 700,
              ),
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                children: [
                  authForm(context, model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneNumberField extends HookViewModelWidget<AuthViewModel> {
  final VoidCallback sendSMSCode;
  _PhoneNumberField({required this.sendSMSCode});

  @override
  Widget buildViewModelWidget(BuildContext context, AuthViewModel model) {
    final phoneNumber = useTextEditingController();
    return PhoneTextField(
      controller: phoneNumber,
      hintText: "XXXXXXXXXX",
      onChanged: (phoneNo) => model.setPhoneNo(phoneNo),
      onFieldSubmitted: sendSMSCode,
    );
  }
}
