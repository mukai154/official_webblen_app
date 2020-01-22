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

  Widget infoBubble(String infoHeader, String infoDescription, VoidCallback updateAction) {
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
                  child: Fonts().textW500("Update", 16.0, FlatColors.webblenRed, TextAlign.right),
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
      body: Container(
        child: ListView(
          children: <Widget>[
            infoBubble(
              "Direct Deposit",
              "Free weekly transfers are sent each Monday to account ending in XXXX. Payments may take 2-3 days to arrive in your account.",
              () => PageTransitionService(context: context, currentUser: currentUser).transitionToBankAccoutDetailsPage(),
            ),
            infoBubble(
              "Instant Deposit",
              "Instant deposit is set up. Earnings are transferred to Debit Card ending in XXXX upon request.",
              () => PageTransitionService(context: context, currentUser: currentUser).transitionToDebitCardDetailsPage(),
            ),
          ],
        ),
      ),
    );
  }
}
