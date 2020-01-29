import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/stripe_services.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class EarningsPage extends StatefulWidget {
  final WebblenUser currentUser;

  EarningsPage({
    this.currentUser,
  });

  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  WebblenUser currentUser;
  bool stripeAccountIsSetup = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        'Earnings',
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.piggyBank, color: FlatColors.darkGray, size: 24.0),
              onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToPayoutMethodsPage(),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.questionCircle, color: FlatColors.darkGray, size: 24.0),
              onPressed: () => PageTransitionService(context: context).transitionToEarningsInfoPage(),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
            stream: Firestore.instance.collection("stripe").document(widget.currentUser.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return Text("Loading...");
              var userData = userSnapshot.data;
              double accountBalance = 0.001;
              if (userData.data != null) {
                accountBalance = userData.data['balance'];
              }
              return userData.data == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 150.0),
                        Fonts().textW600("You're Account Needs to Be Set Up to Receive Payments", 14.0, Colors.black, TextAlign.center),
                        CustomColorButton(
                          text: "Setup Earnings Account",
                          textSize: 16.0,
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          onPressed: () => StripeServices().connectToStripeAccount(context, widget.currentUser.uid),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 32.0),
                        Fonts().textW700(
                          '\$' + accountBalance.toStringAsFixed(2),
                          34,
                          Colors.black,
                          TextAlign.center,
                        ),
                        Fonts().textW600(
                          'Account Balance',
                          18,
                          Colors.black,
                          TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomColorButton(
                              text: 'Instant Deposit',
                              textSize: 18.0,
                              height: 35.0,
                              width: 175.0,
                              backgroundColor: FlatColors.darkMountainGreen,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 32.0),
                        Divider(
                          indent: 18.0,
                          endIndent: 18.0,
                          thickness: 1.0,
                        ),
                        Fonts().textW300(
                          "You Don't Have Any Recent Transactions",
                          18,
                          Colors.black45,
                          TextAlign.center,
                        ),
                      ],
                    );
            }),
      ),
    );
  }
}
