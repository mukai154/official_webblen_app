import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/earnings/set_up_instant_deposit/set_up_instant_deposit_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class SetupInstantDepositView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SetupInstantDepositViewModel>.reactive(
      viewModelBuilder: () => SetupInstantDepositViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Set Up Instant Deposit",
          showBackButton: true,
        ),
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.0),
                      CustomText(
                        text: "Add your debit card details to receive instant deposits into your bank account.",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 8.0),
                      CustomText(
                        text:
                            "To keep your earnings secure, payments from Webblen will be placed on hold for 24 hours. Once your bank account has been verified, any earnings from Webblen during this time will be paid out to your account on the following Monday. This is to ensure your earnings go to your bank account.",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 32.0),
                      CustomText(
                        text: "Card Number",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 8.0),
                      _CardNumField(),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomText(
                                  text: "Exp Month",
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: appFontColor(),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 8.0),
                                _ExpiryMonthField(),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomText(
                                  text: "Exp Year",
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: appFontColor(),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 8.0),
                                _ExpiryYearField(),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomText(
                                  text: "CVC",
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: appFontColor(),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 8.0),
                                _CVCField(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      CustomText(
                        text: "Card Holder Name",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 8.0),
                      _CardHolderNameField(),
                      SizedBox(height: 32.0),
                      CustomText(
                        text: "Please confirm your card details before submission. \n Incorrect details may lead to delayed payments.",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: appFontColor(),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.0),
                      CustomButton(
                        text: "Submit",
                        textSize: 16,
                        textColor: appFontColor(),
                        backgroundColor: appButtonColor(),
                        height: 45.0,
                        width: screenWidth(context),
                        onPressed: () => model.submit(),
                        elevation: 1,
                        isBusy: model.isBusy,
                      ),
                      SizedBox(height: 16.0),
                      CustomText(
                        text: "All data is sent via 256-bit encrypted connection to keep your information secure.",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: appFontColor(),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumField extends HookViewModelWidget<SetupInstantDepositViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, SetupInstantDepositViewModel model) {
    var cardNumField = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});

    return TextFieldContainer(
      child: TextFormField(
        controller: cardNumField,
        decoration: InputDecoration(
          hintText: "XXXX XXXX XXXX XXXX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          String maskedText = maskFormatter.maskText(val);
          cardNumField.text = maskedText;
          cardNumField.selection = TextSelection.fromPosition(TextPosition(offset: cardNumField.text.length));
          model.updateCardNumber(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(19),
        ],
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
        autocorrect: false,
      ),
    );
  }
}

class _ExpiryMonthField extends HookViewModelWidget<SetupInstantDepositViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, SetupInstantDepositViewModel model) {
    var expiryMonth = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '##', filter: {"#": RegExp(r'[0-9]')});
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        controller: expiryMonth,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "XX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          String maskedText = maskFormatter.maskText(val);
          expiryMonth.text = maskedText;
          expiryMonth.selection = TextSelection.fromPosition(TextPosition(offset: expiryMonth.text.length));
          model.updateExpiryMonth(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _ExpiryYearField extends HookViewModelWidget<SetupInstantDepositViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, SetupInstantDepositViewModel model) {
    var expiryYear = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '##', filter: {"#": RegExp(r'[0-9]')});
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        controller: expiryYear,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "XX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          String maskedText = maskFormatter.maskText(val);
          expiryYear.text = maskedText;
          expiryYear.selection = TextSelection.fromPosition(TextPosition(offset: expiryYear.text.length));
          model.updateExpiryYear(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _CVCField extends HookViewModelWidget<SetupInstantDepositViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, SetupInstantDepositViewModel model) {
    var cvc = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '###', filter: {"#": RegExp(r'[0-9]')});
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        controller: cvc,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "XXX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          String maskedText = maskFormatter.maskText(val);
          cvc.text = maskedText;
          cvc.selection = TextSelection.fromPosition(TextPosition(offset: cvc.text.length));
          model.updateCVC(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _CardHolderNameField extends HookViewModelWidget<SetupInstantDepositViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, SetupInstantDepositViewModel model) {
    var cardHolderName = useTextEditingController();
    return TextFieldContainer(
      child: TextFormField(
        controller: cardHolderName,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: model.updateCardHolderName,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}
