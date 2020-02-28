import 'package:flutter/material.dart';

import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class ChooseSimPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget optionsButton(String buttonName, VoidCallback onPressed) {
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(
          top: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 70,
              margin: EdgeInsets.only(
                left: 16,
                top: 30,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      'Choose an Area',
                      32,
                      Colors.black,
                      TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            optionsButton(
                "Fargo, ND",
                () => PageTransitionService(
                      context: context,
                      simLocation: 'Fargo',
                      simLat: 46.877186,
                      simLon: -96.789803,
                    ).transitionToSim()),
            optionsButton(
                "Grand Forks, ND",
                () => PageTransitionService(
                      context: context,
                      simLocation: 'Grand Forks',
                      simLat: 47.925259,
                      simLon: -97.032852,
                    ).transitionToSim()),
            optionsButton(
                "Moorhead, MN",
                () => PageTransitionService(
                      context: context,
                      simLocation: 'Moorhead',
                      simLat: 46.873810,
                      simLon: -96.767822,
                    ).transitionToSim()),
          ],
        ),
      ),
    );
  }
}
