
import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/styles/fonts.dart';

class SplashPage extends StatelessWidget {

  void onGetStartedButtonPressed(BuildContext context) {
    PageTransitionService(context: context).transitionToLoginPage();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 64.0),
            Fonts().textW700('Welcome to Webblen', 30.0, Colors.black, TextAlign.center),
            Fonts().textW300('The World’s First Community Building Platform', 14.0, Colors.black, TextAlign.center),
            Padding(
              padding: EdgeInsets.only(top: 16.0, left:  8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: 145,
                    height: 100,
                    child: Image.asset(
                      "assets/images/onboardingsvg1.png",
                      fit: BoxFit.none,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 150.0
                    ),
                    child: Fonts().textW500("Discover meetups and events happening in your community", 14.0, Colors.black, TextAlign.center),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0, left:  8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: 145,
                    height: 100,
                    child: Image.asset(
                      "assets/images/onboardsvg3.png",
                      fit: BoxFit.none,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 150.0
                    ),
                    child: Fonts().textW500("Know about the news happening in your area", 14.0, Colors.black, TextAlign.center),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0, left:  8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: 145,
                    height: 100,
                    child: Image.asset(
                      "assets/images/onboardingsvg2.png",
                      fit: BoxFit.none,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 150.0
                    ),
                    child: Fonts().textW500( "Earn money and rewards for being involved and attending events", 14.0, Colors.black, TextAlign.center),
                  )
                ],
              ),
            ),
            SizedBox(height: 32.0),
            CustomColorButton(
              height: 45.0,
              width: 200.0,
              hPadding: 8.0,
              vPadding: 8.0,
              text: 'GET STARTED',
              textColor: Colors.black,
              onPressed: () => onGetStartedButtonPressed(context),
            )
          ],
        ),
      ),
    );
  }
}