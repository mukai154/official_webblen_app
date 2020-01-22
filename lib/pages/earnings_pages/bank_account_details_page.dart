import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/banking_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class BankAccountDetailsPage extends StatefulWidget {
  final WebblenUser currentUser;

  BankAccountDetailsPage({
    this.currentUser,
  });

  @override
  _BankAccountDetailsPageState createState() => _BankAccountDetailsPageState();
}

class _BankAccountDetailsPageState extends State<BankAccountDetailsPage> {
  WebblenUser currentUser;
  BankingInfo userBankingInfo;

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
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Bank Account Details", context),
      body: Container(
        child: StreamBuilder(
            stream: Firestore.instance.collection("banking_info").document(widget.currentUser.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData)
                return Text(
                  "Loading...",
                );
              Map<String, dynamic> userData = userSnapshot.data.data;
              BankingInfo bankingInfo = BankingInfo.fromMap(userData);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  bankInfoBubble(bankingInfo),
                ],
              );
            }),
      ),
    );
  }
}
