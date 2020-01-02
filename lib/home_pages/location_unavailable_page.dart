import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';

class LocationUnavailablePage extends StatelessWidget {

  final WebblenUser currentUser;
  LocationUnavailablePage({this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          currentUser.isOnWaitList
              ? Fonts().textW700("You're On the Waitlist", 18.0, FlatColors.darkGray, TextAlign.center)
              : Fonts().textW700("It Looks Like Webblen Isn't In Your Area Yet 😥", 24.0, FlatColors.darkGray, TextAlign.center),
          SizedBox(height: 8.0),
          currentUser.isOnWaitList
              ? Fonts().textW500("We'll Notify You When We're Around. Don't You Worry 😉", 14.0, FlatColors.darkGray, TextAlign.center)
              : Fonts().textW500("Join our Waitlist and We'll Notify You When We're Around", 14.0, FlatColors.darkGray, TextAlign.center),
          SizedBox(height: 12.0),
          currentUser.isOnWaitList
              ? Container()
              : CustomColorButton(
            text: "Join Waitlist",
            textColor: FlatColors.darkGray,
            backgroundColor: FlatColors.clouds,
            height: 40.0,
            width: 200.0,
            onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToWaitListPage(),
          ),
          CustomColorButton(
            text: "See How This Works",
            textColor: FlatColors.darkGray,
            backgroundColor: FlatColors.clouds,
            height: 40.0,
            width: 200.0,
            onPressed: (){
              Navigator.of(context).pop();
              PageTransitionService(context: context).transitionToChooseSim();
            },
          ),
        ],
      ),
    );
  }
}
