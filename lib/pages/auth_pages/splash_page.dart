import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: CustomText(
                        context: context,
                        text: "Welcome to Webblen",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 35.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: CustomText(
                        context: context,
                        text: "Find Events. Build Communities. Get Paid.",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomColorButton(
                  height: 45.0,
                  width: 200.0,
                  text: 'GET STARTED',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  onPressed: () => PageTransitionService(context: context).transitionToLoginPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
