import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';

class HowWebblenWorksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar('How WBLN Works', context),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 16.0,
            ),
            Fonts().textW700(
              'WBLN Balance',
              24,
              Colors.black,
              TextAlign.left,
            ),
            SizedBox(
              height: 16.0,
            ),
            Fonts().textW400(
              "Your WBLN balance is the amount of WBLN tokens you have earned for using the app.",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 8.0,
            ),
            Fonts().textW600(
              "This amount varies according to:",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "• How Many People Attend the Events You Host",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "• How Often You Attend Events",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "• How Many People View Your Streams",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "• How Many Streams You Watch",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "• How Many Comments Your Posts Get",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "• How Often You Comment On Posts",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "• And More!",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 8.0,
            ),
            Fonts().textW400(
              "As long as you are involved in what's happening around you, you can earn WBLN.",
              16,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 32.0,
            ),
            Fonts().textW700(
              'What Can I Use WBLN For?',
              24,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 4.0,
            ),
            Fonts().textW400(
              "WBLN Allows You to:",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(height: 8.0),
            Fonts().textW400(
              "-Post messages, images, events, and streams",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            Fonts().textW400(
              "-Earn cash rewards and exclusive discounts/gifts from verified local vendors.",
              14,
              Colors.black87,
              TextAlign.left,
            ),
            SizedBox(
              height: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
