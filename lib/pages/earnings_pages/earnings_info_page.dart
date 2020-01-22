import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';

class EarningsInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar('How Earnings Work', context),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 16.0,
            ),
            Fonts().textW600(
              'Account Balance',
              24,
              Colors.black,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "Your account balance is the amount of money you have available to transfer to your bank account this week. \nThis amount varies if:",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "- You have collected cash from customers.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "- You have initiated an instant deposit this week.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 32.0,
            ),
            Fonts().textW600(
              'Payout Schedule',
              24,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "You get paid on a weekly basis for tickets you distribute on the mobile app, Webblen. Payouts are completed betweet Monday - Sunday of the previous week (ending Sunday at midnight CST). Payments are transferred at that time directly to your bank account through Direct Deposit, and usually take 2-3 days to show up in your bank account. Payments should appear in your bank account by Wednesday night.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 16.0,
            ),
            Fonts().textW600(
              'Instant Deposits',
              18,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "You have the ability to cashout your earnings daily for a fee of 1% the total deposit. This allows you to receive your earnings from ticket sales on demand from Webblen rather than waiting a week via direct deposit.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "You must have a valid debit card - not a prepaid card - to use Webblen's instant deposit service.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
