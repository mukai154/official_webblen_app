import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class CustomAppBar {
  Widget basicAppBar({@required String title, @required bool showBackButton}) {
    return AppBar(
      elevation: 0,
      backgroundColor: appBackgroundColor(),
      title: Text(
        title,
        style: TextStyle(
          color: appFontColor(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: appBrightness(),
      leading: showBackButton ? BackButton(color: appIconColor()) : Container(),
      bottom: PreferredSize(
        child: Container(
          color: appBorderColor(),
          height: 1.0,
        ),
        preferredSize: Size.fromHeight(4.0),
      ),
    );
  }

  Widget basicActionAppBar({@required String title, @required bool showBackButton, @required actionWidget}) {
    return AppBar(
      elevation: 0,
      backgroundColor: appBackgroundColor(),
      title: Text(
        title,
        style: TextStyle(
          color: appFontColor(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: appBrightness(),
      leading: showBackButton ? BackButton(color: appIconColor()) : Container(),
      actions: [
        actionWidget,
      ],
      bottom: PreferredSize(
        child: Container(
          color: appBorderColor(),
          height: 1.0,
        ),
        preferredSize: Size.fromHeight(4.0),
      ),
    );
  }
}
