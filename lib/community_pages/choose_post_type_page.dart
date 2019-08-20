import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/widgets_common/common_appbar.dart';

class ChoosePostTypePage extends StatelessWidget {

  final WebblenUser currentUser;
  final Community community;
  ChoosePostTypePage({this.currentUser, this.community});

  @override
  Widget build(BuildContext context) {

    Widget optionsButton(String buttonName, VoidCallback onPressed){
      return CustomColorButton(
        text: buttonName,
        textColor: FlatColors.darkGray,
        backgroundColor: Colors.white,
        height: 40.0,
        width: 200.0,
        onPressed: onPressed,
      );
    }

    return Scaffold(
      appBar: WebblenAppBar().basicAppBar('Add'),
      body: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Fonts().textW700("What Would You Like to Add?", 20.0, FlatColors.darkGray, TextAlign.center),
              SizedBox(height: 24.0),
              optionsButton("Special Event", () => PageTransitionService(context: context, currentUser: currentUser, community: community, isRecurring: false).transitionToNewEventPage()),
              optionsButton("Regular/Repeating Event", () => PageTransitionService(context: context, currentUser: currentUser, community: community).transitionToNewRecurringEventPage()),
              optionsButton("News Post", () => PageTransitionService(context: context, currentUser: currentUser, community: community).transitionToCommunityCreatePostPage()),
            ],
          )
      ),
    );
  }
}


