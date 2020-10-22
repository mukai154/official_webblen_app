import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/firebase/data/stripe_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class SetUpDirectDepositPage extends StatefulWidget {
  final WebblenUser currentUser;

  SetUpDirectDepositPage({
    this.currentUser,
  });

  @override
  _SetUpDirectDepositPageState createState() => _SetUpDirectDepositPageState();
}

class _SetUpDirectDepositPageState extends State<SetUpDirectDepositPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bankingForm = GlobalKey<FormState>();
  WebblenUser currentUser;
  String stripeUID;
  String accountHolderName;
  String accountHolderType = 'individual';
  String routingNumber;
  String accountNumber;
  List<String> accountHolderTypes = ['individual', 'company'];

  void validateAndSubmitForm() {
    ShowAlertDialogService().showLoadingDialog(context);
    bankingForm.currentState.save();
    ScaffoldState scaffoldState = scaffoldKey.currentState;
    if (accountHolderName == null || accountHolderName.isEmpty) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Please Enter a Name for the Account"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (routingNumber == null || routingNumber.length != 9) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Please Enter a Valid Routing Number"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (accountNumber == null || accountNumber.isEmpty) {
      Navigator.of(context).pop();
      scaffoldState.showSnackBar(
        SnackBar(
          content: Text("Please Enter a Valid Account Number"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      StripeDataService()
          .submitBankingInfoToStripe(currentUser.uid, stripeUID, accountHolderName, accountHolderType, routingNumber, accountNumber)
          .then((status) {
        print(status);
        if (status == "passed") {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(context, "There was an Issue Adding Your Account", "Please Verify Your Info and Try Again.");
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    StripeDataService().getStripeUID(currentUser.uid).then((val) {
      if (val != null) {
        stripeUID = val;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountHolderNameField = Container(
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
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onSaved: (val) => accountHolderName = val,
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

    final accountHolderTypeField = Container(
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
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          underline: Container(),
          isDense: true,
          isExpanded: true,
          value: accountHolderType,
          items: accountHolderTypes.map((val) {
            return DropdownMenuItem(
              child: Fonts().textW500(val, 16.0, Colors.black, TextAlign.left),
              value: val,
            );
          }).toList(),
          onChanged: (selectedValue) {
            setState(() {
              accountHolderType = selectedValue;
            });
          },
        ),
      ),
    );

    final routingNumberField = Container(
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
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onSaved: (val) => routingNumber = val,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final accountNumberField = Container(
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
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onSaved: (val) => accountNumber = val,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: WebblenAppBar().basicAppBar("Set Up Direct Deposit", context),
      body: Container(
        color: Colors.white,
        child: Form(
          key: bankingForm,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 32.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 32.0),
                child: Fonts().textW700(
                  "Add your bank details to receive your earnings directly into your bank account.",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 16.0,
                ),
                child: Fonts().textW400(
                  "To keep your earnings secure, payments from Webblen will be placed on hold for 24 hours. Once your bank account has been verified, any earnings from Webblen during this time will be paid out to your account on the following Monday. This is to ensure your earnings go to your bank account.",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "NAME ON BANK ACCOUNT",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              accountHolderNameField,
              Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "ACCOUNT TYPE",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              accountHolderTypeField,
              Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "ROUTING NUMBER",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              routingNumberField,
              Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW700(
                  "ACCOUNT NUMBER",
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ),
              accountNumberField,
              GestureDetector(
                onTap: () => ShowAlertDialogService().showCheckExampleDialog(context),
                child: Fonts().textW500(
                  "Where Do I Find These Numbers?",
                  14.0,
                  Colors.black54,
                  TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 64.0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 4.0,
                ),
                child: Fonts().textW400(
                  "Please confirm your bank details before sumbission. \n Incorrect details may lead to delayed payments.",
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
