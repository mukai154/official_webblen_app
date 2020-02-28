import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';

class PayoutMethodsPage extends StatefulWidget {
  final WebblenUser currentUser;

  PayoutMethodsPage({
    this.currentUser,
  });

  @override
  _PayoutMethodsPageState createState() => _PayoutMethodsPageState();
}

class _PayoutMethodsPageState extends State<PayoutMethodsPage> {
  WebblenUser currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  Widget infoBubble(String infoHeader, String infoDescription, bool isSetUp, VoidCallback updateAction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45, width: 0.3),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Fonts().textW600(infoHeader, 24.0, Colors.black, TextAlign.left),
                GestureDetector(
                  onTap: updateAction,
                  child: Fonts().textW500(isSetUp ? "Update" : "Set Up", 16.0, isSetUp ? FlatColors.webblenRed : Colors.black45, TextAlign.right),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Fonts().textW400(
                    infoDescription,
                    16.0,
                    Colors.black,
                    TextAlign.left,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Payout Methods", context),
      body: StreamBuilder(
          stream: Firestore.instance.collection("stripe").document(widget.currentUser.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) return Text("Loading...");
            var userData = userSnapshot.data.data;
            Map<String, dynamic> bankInfo = userData['bankInfo'] == null ? null : Map<String, dynamic>.from(userData['bankInfo']);
            Map<String, dynamic> cardInfo = userData['cardInfo'] == null ? null : Map<String, dynamic>.from(userData['cardInfo']);
            return Container(
              child: ListView(
                children: <Widget>[
                  bankInfo == null
                      ? infoBubble(
                          "Direct Deposit",
                          "Direct deposit is not set up. Please fill out your banking information in order to receive direct deposits.",
                          false,
                          () => PageTransitionService(context: context, currentUser: currentUser).transitionToBankAccoutDetailsPage(),
                        )
                      : infoBubble(
                          "Direct Deposit",
                          "Free weekly transfers are sent each Monday to account ending in ${bankInfo['last4']}. Payments may take 2-3 days to arrive in your account.",
                          true,
                          () => PageTransitionService(context: context, currentUser: currentUser).transitionToBankAccoutDetailsPage(),
                        ),
                  cardInfo == null
                      ? infoBubble(
                          "Instant Deposit",
                          "Instant deposit is not set up. Please fill out your card information in order to receive instant deposits.",
                          false,
                          () => PageTransitionService(context: context, currentUser: currentUser).transitionToDebitCardDetailsPage(),
                        )
                      : infoBubble(
                          "Instant Deposit",
                          "Instant deposit is set up. Earnings are transferred to Debit Card ending in ${cardInfo['last4']} upon request.",
                          true,
                          () => PageTransitionService(context: context, currentUser: currentUser).transitionToDebitCardDetailsPage(),
                        ),
                ],
              ),
            );
          }),
    );
  }
}
