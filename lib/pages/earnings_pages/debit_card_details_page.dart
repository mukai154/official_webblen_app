import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
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
  PaymentMethod _paymentMethod;
  WebblenUser currentUser;
  DebitCardInfo userDebitCardInfo;

  void setError(dynamic error) {
//Handle your errors
  }

  void addStripeCard() {
    print('testing...');
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) {
      //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
      setState(() {
        _paymentMethod = paymentMethod;
      });
      print(paymentMethod.card.funding);
      print(paymentMethod.card.last4);
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_test_gYHQOvqAIkPEMVGQRehk3nj4009Kfodta1",
        merchantId: "test",
        androidPayMode: 'test',
      ),
    );
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
            onPressed: () => addStripeCard(),
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
