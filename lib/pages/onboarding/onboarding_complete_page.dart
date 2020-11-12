import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';

class AnimatedNumText extends AnimatedWidget {
  final Animation<double> animation;
  final double fontSize;
  final bool animationComplete;
  AnimatedNumText({Key key, this.animation, this.fontSize, this.animationComplete}) : super(key: key, listenable: animation);

  @override
  build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      child: Text("+${animation.value.toStringAsFixed(2)} WBBLN"),
      style: animationComplete
          ? TextStyle(
              color: CustomColors.darkMountainGreen,
              fontSize: 35,
              fontWeight: FontWeight.w700,
            )
          : fontSize == 25.0
              ? TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                )
              : TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
      duration: animationComplete ? Duration(milliseconds: 200) : Duration(milliseconds: 100),
    );
  }
}

class OnboardingCompletePage extends StatefulWidget {
  @override
  _OnboardingCompletePageState createState() => _OnboardingCompletePageState();
}

class _OnboardingCompletePageState extends State<OnboardingCompletePage> with TickerProviderStateMixin {
  Timer timer;
  AnimationController animationController;
  bool animationComplete = false;
  double webblenReward = 0.01;
  Color webblenTextColor = CustomColors.darkMountainGreen;
  double fontSize = 25.0;

  depositWebblenAnimation() async {
    animationController.forward(from: 0.00);
  }

  @override
  initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((userID) {
      WebblenUserData().depositWebblen(5.001, userID);
    });
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    animationController.forward(from: 0.00);
    animationController.addListener(() {
      if (animationController.isCompleted) {
        setState(() {
          animationComplete = true;
        });
        HapticFeedback.heavyImpact();
      }
    });
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      if (!animationComplete) {
        if (fontSize == 25) {
          fontSize = 30;
        } else {
          fontSize = 25;
          HapticFeedback.lightImpact();
        }
        setState(() {});
      }
    });
    //animation = CurvedAnimation(parent: animationController, curve: Curves.easeInBack);
    //
  }

  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedNumText(
                  fontSize: fontSize,
                  animationComplete: animationComplete,
                  animation: Tween<double>(
                    begin: 0,
                    end: 5,
                  ).animate(animationController),
                ),
              ],
            ),
            AnimatedOpacity(
              // If the widget is visible, animate to 0.0 (invisible).
              // If the widget is hidden, animate to 1.0 (fully visible).
              opacity: animationComplete ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              // The green box must be a child of the AnimatedOpacity widget.
              child: Container(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/money_jar.png',
                      height: 200,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You're All Set!\nHere's Some Webblen!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Earn Webblen for attending events, viewing streams, and being involved. Webblen can be traded for merch, gift cards, and cash prizes in our shop.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, height: 1.5),
                    ),
                    SizedBox(height: 8.0),
                    CustomColorButton(
                      text: 'Finish',
                      textColor: Colors.black,
                      backgroundColor: Colors.white,
                      height: 45.0,
                      width: 200.0,
                      onPressed: () => PageTransitionService(context: context).transitionToRootPage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
