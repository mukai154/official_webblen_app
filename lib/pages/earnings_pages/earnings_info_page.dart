import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';

class EarningsInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar('How Earnings Work', context),
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 16.0,
            ),
            Fonts().textW700(
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
            Fonts().textW400(
              "- You have sold tickets for your event(s).",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "- You have received gifts or donations through for your stream(s).",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 32.0,
            ),
            Fonts().textW700(
              'Payout Schedule',
              24,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "You get paid for tickets you distribute and donations/gifts you receive through live streams. You get paid on a weekly basis for tickets while money received through donations or gifts are paid out monthly.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(height: 8.0),
            Fonts().textW400(
              "Payouts are completed between Monday - Sunday of the previous week (ending Sunday at midnight CST). Payments are transferred at that time directly to your bank account through Direct Deposit, and usually take 2-3 days to show up in your bank account. Payments should appear in your bank account by Wednesday night.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 16.0,
            ),
            Fonts().textW700(
              'Instant Deposits',
              18,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "You have the ability to cash-out your earnings daily for a fee of up to 1.5% the total deposit. This allows you to receive your earnings from ticket sales, gifts, and donations on demand from Webblen rather than waiting for a direct deposit.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 8.0,
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
