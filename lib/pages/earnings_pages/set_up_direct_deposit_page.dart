import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/models/banking_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
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
  WebblenUser currentUser;
  String routingNumber;
  String accountNumber;
  String confirmAccountNumber;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  Widget bankInfoBubble(BankingInfo bankingInfo) {
    String accountNumber = bankingInfo.accountNumber.toString();
    String last4OfAccountNumber = "......." + accountNumber.substring(accountNumber.length - 4, accountNumber.length);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black38, width: 0.3),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 32.0,
          ),
          Fonts().textW500(
            "Name on Account",
            16.0,
            Colors.black38,
            TextAlign.right,
          ),
          Fonts().textW700(
            bankingInfo.nameOnAccount,
            24.0,
            Colors.black,
            TextAlign.right,
          ),
          SizedBox(
            height: 32.0,
          ),
          Fonts().textW500(
            "Bank Account",
            16.0,
            Colors.black38,
            TextAlign.center,
          ),
          Fonts().textW700(
            bankingInfo.bankName,
            24.0,
            Colors.black,
            TextAlign.center,
          ),
          Fonts().textW700(
            last4OfAccountNumber,
            24.0,
            Colors.black,
            TextAlign.center,
          ),
          SizedBox(
            height: 32.0,
          ),
          Fonts().textW500(
            "Verification Status",
            16.0,
            Colors.black38,
            TextAlign.center,
          ),
          Fonts().textW600(
            bankingInfo.verified ? "Your identity is verified and you are receiving payments." : "unverified",
            16.0,
            Colors.black,
            TextAlign.center,
          ),
          SizedBox(
            height: 16.0,
          ),
          CustomColorButton(
            text: "Update Information",
            textColor: Colors.white,
            backgroundColor: FlatColors.webblenRed,
            height: 40.0,
            width: 175.0,
            onPressed: null,
          ),
          SizedBox(
            height: 32.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // **ROUTING NUMBER FIELD
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

    final confirmAccountNumberField = Container(
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
        onSaved: (val) => confirmAccountNumber = val,
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
      appBar: WebblenAppBar().basicAppBar("Set Up Direct Deposit", context),
      body: Container(
        color: Colors.white,
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
              onTap: null,
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
    );
  }
}
