import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/firebase_services/transaction_data.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase_services/reward_data.dart';


class RewardPayoutPage extends StatefulWidget {

  final WebblenReward redeemingReward;
  final WebblenUser currentUser;
  RewardPayoutPage({this.redeemingReward, this.currentUser});

  @override
  _RewardPayoutPageState createState() => _RewardPayoutPageState();
}

class _RewardPayoutPageState extends State<RewardPayoutPage> {

  GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();
  String formDepositName;
  String formDepositNameInput;
  String formDepositNameInputConfirmation;

  String showFormDepositLabel(){
    String formDepositType = "";
    if (widget.redeemingReward.rewardType == 'giftCard' || widget.redeemingReward.rewardType == 'paypal'){
      formDepositType = "Email:";
    } else if (widget.redeemingReward.rewardType == 'venmo'){
      formDepositType = "Venmo Username:";
    } else {
      formDepositType = "CashApp Username:";
    }
    return formDepositType;
  }

  String showFormDepositNameHint(){
      String formDepositNameHint = "";
      if (widget.redeemingReward.rewardType == 'giftCard' || widget.redeemingReward.rewardType == 'paypal'){
        formDepositNameHint = "email address";
      } else if (widget.redeemingReward.rewardType == 'venmo'){
        formDepositNameHint = "venmo username";
      } else {
        formDepositNameHint = "cashapp username";
      }
      return formDepositNameHint;
  }

  bool paymentFormIsValid(){
    bool isValid = false;
    final form = paymentFormKey.currentState;
    if (form.validate()) {
      form.save();
      if (formDepositNameInput != formDepositNameInputConfirmation){
        ShowAlertDialogService().showFailureDialog(context, "Payment Error", 'Deposit Accounts Do Not Match');
      } else {
        isValid = true;
      }
    }
    return isValid;
  }

  validateAndSubmitPaymentForm()  {
    if (paymentFormIsValid()){
      ShowAlertDialogService().showLoadingDialog(context);
      TransactionDataService().submitTransaction(widget.currentUser.uid, null, widget.redeemingReward.rewardType, formDepositNameInput, widget.redeemingReward.rewardDescription).then((error){
        if (error.isEmpty){
          RewardDataService().removeUserReward(widget.currentUser.uid, widget.redeemingReward.rewardKey).then((error){
            if (error.isEmpty){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ShowAlertDialogService().showSuccessDialog(context, "Payment Now Processing", "Please Allow 2-3 Days for Your Payment to be Deposited into Your Account");
            }
          });
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(context, "Payment Failed", "There was an issue processing your payment, please try again");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    final rewardPayoutForm = Container(
      child: new GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Form(
              key: paymentFormKey,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      style: TextStyle(color: FlatColors.darkGray),
                      keyboardType: widget.redeemingReward.rewardType == 'giftCard' || widget.redeemingReward.rewardType == 'paypal'
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      autofocus: false,
                      validator: (value) => value.isEmpty ? 'Required' : null,
                      onSaved: (value) => formDepositNameInput = value,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: widget.redeemingReward.rewardType == 'giftCard' || widget.redeemingReward.rewardType == 'paypal'
                            ? Icon(FontAwesomeIcons.envelope, color: FlatColors.darkGray)
                            : Icon(FontAwesomeIcons.userTag, color: FlatColors.darkGray),
                        hintText: showFormDepositNameHint(),
                        hintStyle: TextStyle(color: Colors.black12),
                        errorStyle: TextStyle(color: Colors.red),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(color: FlatColors.darkGray),
                      keyboardType: widget.redeemingReward.rewardType == 'giftCard' || widget.redeemingReward.rewardType == 'paypal'
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      autofocus: false,
                      validator: (value) => value.isEmpty ? 'Required' : null,
                      onSaved: (value) => formDepositNameInputConfirmation = value,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(FontAwesomeIcons.checkCircle, color: FlatColors.darkGray),
                        hintText: "confirm " + showFormDepositNameHint(),
                        hintStyle: TextStyle(color: Colors.black12),
                        errorStyle: TextStyle(color: Colors.red),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      ),
                    ),
                    CustomColorButton(
                        text: "Confirm",
                        textColor: FlatColors.darkMountainGreen,
                        backgroundColor: Colors.white,
                        height: 45.0,
                        width: 200.0,
                        onPressed: () => validateAndSubmitPaymentForm()
                    ),
                    CustomColorButton(
                        text: "Cancel",
                        textColor: FlatColors.londonSquare,
                        backgroundColor: Colors.white,
                        height: 45.0,
                        width: 200.0,
                        onPressed: () => Navigator.pop(context)
                    ),
                  ],
                ),
              )
          )
      ),
    );



    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Redeem Reward"),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width:  MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width:  MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Fonts().textW500(widget.redeemingReward.rewardProviderName, 18.0, FlatColors.darkGray, TextAlign.center),
                    SizedBox(height: 4.0),
                    Fonts().textW500("Please Fill Out the Form Below to Receive Your Reward", 12.0, FlatColors.lightAmericanGray, TextAlign.center),
                    rewardPayoutForm,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
