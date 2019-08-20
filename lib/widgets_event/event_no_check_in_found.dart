import 'package:flutter/material.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';


class EventNoCheckInFound extends StatelessWidget {

  final VoidCallback createFlashEventAction;
  EventNoCheckInFound({this.createFlashEventAction});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 180.0),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child:
          Fonts().textW500("There are Currently No Availabe Events Nearby", 16.0, FlatColors.darkGray, TextAlign.center),
        ),
        SizedBox(height: 8.0),
        CustomColorButton(
          text: "Create Flash Event",
          textColor: FlatColors.darkGray,
          backgroundColor: Colors.white,
          height: 45.0,
          width: 200.0,
          onPressed: createFlashEventAction,
        ),
      ],
    );
  }
}
