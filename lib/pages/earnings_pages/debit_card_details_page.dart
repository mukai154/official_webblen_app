import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/debit_card_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class DebitCardDetailsPage extends StatefulWidget {
  final WebblenUser currentUser;

  DebitCardDetailsPage({
    this.currentUser,
  });

  @override
  _DebitCardDetailsPageState createState() => _DebitCardDetailsPageState();
}

class _DebitCardDetailsPageState extends State<DebitCardDetailsPage> {
  WebblenUser currentUser;
  DebitCardInfo userDebitCardInfo;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  Widget debitCardInfoBubble(DebitCardInfo debitCardInfo) {
    String cardNumber = debitCardInfo.cardNumber.toString();
    String last4OfCardNumber = "**** **** **** " + cardNumber.substring(cardNumber.length - 4, cardNumber.length);
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            height: 32.0,
          ),
          Fonts().textW500(
            "Name on Card",
            16.0,
            Colors.black38,
            TextAlign.right,
          ),
          Fonts().textW700(
            debitCardInfo.nameOnCard,
            24.0,
            Colors.black,
            TextAlign.right,
          ),
          SizedBox(
            height: 32.0,
          ),
          Fonts().textW500(
            "Card Details",
            16.0,
            Colors.black38,
            TextAlign.center,
          ),
          Fonts().textW700(
            last4OfCardNumber,
            24.0,
            Colors.black,
            TextAlign.center,
          ),
          SizedBox(
            height: 4.0,
          ),
          Fonts().textW700(
            "Expiration Date: 03/20", //debitCardInfo.expMonth.toString() + "/" + debitCardInfo.expYear.toString(),
            16.0,
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
            "Your Card is verified and eligible for Instant Deposit",
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
      appBar: WebblenAppBar().basicAppBar("Debit Card Details", context),
      body: Container(
        child: StreamBuilder(
            stream: Firestore.instance.collection("debit_card_info").document(widget.currentUser.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData)
                return Text(
                  "Loading...",
                );
              Map<String, dynamic> userData = userSnapshot.data.data;
              DebitCardInfo cardInfo = DebitCardInfo.fromMap(userData);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  debitCardInfoBubble(cardInfo),
                ],
              );
            }),
      ),
    );
  }
}
