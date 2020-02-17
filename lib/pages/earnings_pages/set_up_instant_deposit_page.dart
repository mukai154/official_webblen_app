import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webblen/firebase_data/stripe_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class SetUpInstantDepositPage extends StatefulWidget {
  final WebblenUser currentUser;

  SetUpInstantDepositPage({
    this.currentUser,
  });

  @override
  _SetUpInstantDepositPageState createState() => _SetUpInstantDepositPageState();
}

class _SetUpInstantDepositPageState extends State<SetUpInstantDepositPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final cardForm = GlobalKey<FormState>();

  var cardNumberMask = MaskedTextController(mask: '0000 0000 0000 0000');
  var expiryDateMask = MaskedTextController(mask: 'XX/XX');
  bool cvcFocused = false;
  String stripeUID;
  WebblenUser currentUser;
  String cardNumber = "";
  String expiryDate = "MM/YY";
  int expMonth = 1;
  int expYear = 2020;
  String cardHolderName = "";
  String cvcNumber = "";

  cvcFocus(bool focus) {
    if (focus) {
      cvcFocused = true;
    } else {
      cvcFocused = false;
    }
    setState(() {});
  }

  void validateAndSubmitForm() async {
    ShowAlertDialogService().showLoadingDialog(context);
    cardForm.currentState.save();
    ScaffoldState scaffoldState = scaffoldKey.currentState;
    cardNumber = cardNumber.replaceAll(" ", "");
    if (cardNumber == null || cardNumber.length != 16) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Invalid Card Number"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (expMonth < 1 || expMonth > 12) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Invalid Expiry Month"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (expYear < DateTime.now().year) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Invalid Expiry Year"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (cardHolderName == null || cardHolderName.isEmpty) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Name Cannot Be Empty"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (cvcNumber == null || cvcNumber.length != 3) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Invalid CVC Code"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      StripeCard card = StripeCard(number: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvcNumber, name: cardHolderName);
      StripeApi.instance.createPaymentMethodFromCard(card).then((res) {
        if (res['card']['funding'] == 'debit') {
          StripeDataService().submitCardInfoToStripe(currentUser.uid, stripeUID, cardNumber, expMonth, expYear, cvcNumber, cardHolderName).then((res) {
            Navigator.of(context).pop();
            ShowAlertDialogService().showActionSuccessDialog(context, "Card Added!", "You Are Now Eligible for Instant Deposits", () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          });
        } else {
          Navigator.of(context).pop();
          scaffoldState.showSnackBar(
            SnackBar(
              content: Text("Please Use a Valid DEBIT Card"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }).catchError((e) {
        Navigator.of(context).pop();
        String error = e.toString();
        scaffoldState.showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    StripeApi.init("pk_test_gYHQOvqAIkPEMVGQRehk3nj4009Kfodta1");
    StripeDataService().getStripeUID(currentUser.uid).then((val) {
      if (val != null) {
        stripeUID = val;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardNumberField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        controller: cardNumberMask,
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
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
          cvcFocused = false;
          cardNumber = val;
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(19),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final expiryMonthField = Container(
      width: MediaQuery.of(context).size.width * 0.5 - 48,
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "01",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          expMonth = int.parse(val);
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final expiryYearField = Container(
      width: MediaQuery.of(context).size.width * 0.5 - 48,
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "2024",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          expYear = int.parse(val);
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final cardHolderNameField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "Your Name",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          cardHolderName = val;
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    Widget cvcField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
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
          cvcFocused = true;
          cvcNumber = val;
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: WebblenAppBar().basicAppBar("Set Up Instant Deposit", context),
      body: Container(
        color: Colors.white,
        child: Form(
          key: cardForm,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 32.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 32.0),
                child: Fonts().textW700(
                  "Add your debit card details to receive instant deposits into your bank account.",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expMonth <= 9 ? "0$expMonth/$expYear" : "$expMonth/$expYear",
                cardHolderName: cardHolderName,
                cvvCode: cvcNumber,
                showBackView: cvcFocused,
                cardbgColor: FlatColors.webblenRed,
                height: 175,
                textStyle: TextStyle(
                  color: cvcFocused ? Colors.black : Colors.white,
                  fontSize: 18.0,
                  fontFamily: "Helvetica Neue",
                  fontWeight: FontWeight.w400,
                ),
                width: MediaQuery.of(context).size.width,
                animationDuration: Duration(milliseconds: 1000),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "Card Number",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              cardNumberField,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          left: 32.0,
                          right: 32.0,
                          bottom: 4.0,
                        ),
                        child: Fonts().textW700(
                          "Expiry Month",
                          16.0,
                          Colors.black,
                          TextAlign.left,
                        ),
                      ),
                      expiryMonthField,
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          left: 32.0,
                          right: 32.0,
                          bottom: 4.0,
                        ),
                        child: Fonts().textW700(
                          "Expiry Year",
                          16.0,
                          Colors.black,
                          TextAlign.left,
                        ),
                      ),
                      expiryYearField,
                    ],
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "Card Holder Name",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              cardHolderNameField,
              Container(
                margin: EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "CVC",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              cvcField,
              Container(
                margin: EdgeInsets.only(
                  top: 48.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW400(
                  "Please confirm your card details before sumbission. \n Incorrect details may lead to delayed payments.",
                  12.0,
                  Colors.black,
                  TextAlign.center,
                ),
              ),
              CustomColorButton(
                text: "Submit",
                textColor: Colors.white,
                backgroundColor: FlatColors.webblenRed,
                height: 45.0,
                width: MediaQuery.of(context).size.width * 0.6,
                onPressed: () => validateAndSubmitForm(),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 16.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW400(
                  "All data is sent via 256-bit encrypted connection to keep your information secure.",
                  14.0,
                  Colors.black,
                  TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
