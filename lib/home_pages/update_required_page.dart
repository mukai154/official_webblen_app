import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';

class UpdateRequiredPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Fonts().textW700("Update Required", 18.0, FlatColors.darkGray, TextAlign.center),
          SizedBox(height: 4.0),
          Fonts().textW700("Please Update Your Current Version of Webblen", 18.0, FlatColors.darkGray, TextAlign.center),
        ],
      ),
    );
  }
}