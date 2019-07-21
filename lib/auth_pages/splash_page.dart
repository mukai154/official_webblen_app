
import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_common/common_button.dart';

class SplashPage extends StatelessWidget {

  void onGetStartedButtonPressed(BuildContext context) {
    PageTransitionService(context: context).transitionToLoginPage();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 44,
              child: Container(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 301,
                height: 54,
                margin: EdgeInsets.only(left: 36, top: 28),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: Text(
                        "Welcome to Webblen",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 30,
                          fontFamily: "Helvetica Neue",
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Positioned(
                      left: 5,
                      top: 36,
                      child: Text(
                        "The World’s First Community Building Platform",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontFamily: "Helvetica Neue",
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 36, top: 27, right: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 145,
                    height: 100,
                    child: Image.asset(
                      "assets/images/onboardingsvg1.png",
                      fit: BoxFit.none,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Container(
                    width: 152,
                    margin: EdgeInsets.only(top: 29),
                    child: Text(
                      "Discover meetups and events happening in your community",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: "Helvetica Neue",
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 36, top: 20, right: 38),
              child: Row(
                children: [
                  Container(
                    width: 145,
                    height: 100,
                    child: Image.asset(
                      "assets/images/onboardsvg3.png",
                      fit: BoxFit.none,
                    ),
                  ),
                  Container(
                    width: 152,
                    margin: EdgeInsets.only(top: 36),
                    child: Text(
                      "Know about the news happening in your area",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: "Helvetica Neue",
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 36, top: 20, right: 36),
              child: Row(
                children: [
                  Container(
                    width: 145,
                    height: 100,
                    child: Image.asset(
                      "assets/images/onboardingsvg2.png",
                      fit: BoxFit.none,
                    ),
                  ),
                  Container(
                    width: 152,
                    margin: EdgeInsets.only(top: 29),
                    child: Text(
                      "Earn money and rewards for being involved and attending events",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                        fontFamily: "Helvetica Neue",
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 72),
                child: CustomColorButton(
                  height: 45.0,
                  width: 200.0,
                  hPadding: 8.0,
                  vPadding: 8.0,
                  text: 'GET STARTED',
                  textColor: Colors.black,
                  onPressed: () => onGetStartedButtonPressed(context),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}