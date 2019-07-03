import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';

class LocationPermissionsPage extends StatelessWidget {

  final VoidCallback reloadAction;
  LocationPermissionsPage({this.reloadAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          child: Fonts().textW500("Please Enable Location Services to Access All Features", 16.0, FlatColors.darkGray, TextAlign.center),
        ),
        SizedBox(height: 8.0),
        CustomColorButton(
          text: 'Try Again',
          textColor: FlatColors.darkGray,
          backgroundColor: Colors.white,
          height: 45.0,
          width: 100.0,
          hPadding: 16.0,
          onPressed: reloadAction,
        )
      ],
    );
  }
}
