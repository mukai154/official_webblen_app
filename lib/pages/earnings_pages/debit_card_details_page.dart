import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/firebase_data/stripe_data.dart';
import 'package:webblen/models/debit_card_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class DebitCardDetailsPage extends StatefulWidget {
  final WebblenUser currentUser;

  DebitCardDetailsPage({
    this.currentUser,
  });

  @override
  _DebitCardDetailsPageState createState() => _DebitCardDetailsPageState();
}

class _DebitCardDetailsPageState extends State<DebitCardDetailsPage> {
  bool isLoading = true;
  String stripeUID;
  WebblenUser currentUser;
  DebitCardInfo userDebitCardInfo;

  void setError(dynamic error) {
//Handle your errors
  }

  void addStripeCard() {}

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
//    StripePayment.setOptions(
//      StripeOptions(
//        publishableKey: "pk_test_gYHQOvqAIkPEMVGQRehk3nj4009Kfodta1",
//        merchantId: "test",
//        androidPayMode: 'test',
//      ),
//    );
    StripeDataService().getStripeUID(currentUser.uid).then((val) {
      if (val != null) {
        stripeUID = val;
      }
      isLoading = false;
      setState(() {});
    });
  }

  Widget debitCardInfoBubble(DebitCardInfo debitCardInfo) {
    String last4OfCardNumber = "**** **** **** " + debitCardInfo.last4;
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
            height: 16.0,
          ),
          Fonts().textW500(
            "Card Type",
            16.0,
            Colors.black38,
            TextAlign.center,
          ),
          Fonts().textW700(
            debitCardInfo.brand.toUpperCase(),
            24.0,
            Colors.black,
            TextAlign.center,
          ),
          SizedBox(
            height: 16.0,
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
            "Expiration Date: ${debitCardInfo.expMonth}/${debitCardInfo.expYear}", //debitCardInfo.expMonth.toString() + "/" + debitCardInfo.expYear.toString(),
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
            onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToSetUpInstantDepositPage(),
          ),
          SizedBox(
            height: 32.0,
          ),
        ],
      ),
    );
  }

  Widget noCardFoundBubble() {
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
            "Add a Card to Be Eligible for Instant Deposits",
            16.0,
            Colors.black38,
            TextAlign.right,
          ),
          SizedBox(
            height: 16.0,
          ),
          CustomColorButton(
            text: "Add Card",
            textColor: Colors.white,
            backgroundColor: FlatColors.webblenRed,
            height: 40.0,
            width: 175.0,
            onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToSetUpInstantDepositPage(),
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
        child: isLoading
            ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed)
            : StreamBuilder(
                stream: Firestore.instance.collection("stripe").document(widget.currentUser.uid).snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData)
                    return Text(
                      "Loading...",
                    );
                  Map<String, dynamic> userData = userSnapshot.data.data;
                  DebitCardInfo cardInfo = userData['cardInfo'] == null ? null : DebitCardInfo.fromMap(Map<String, dynamic>.from(userData['cardInfo']));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      cardInfo == null ? noCardFoundBubble() : debitCardInfoBubble(cardInfo),
                    ],
                  );
                }),
      ),
    );
  }
}
