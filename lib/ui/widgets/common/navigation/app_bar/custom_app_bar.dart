import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class CustomAppBar {
  Widget basicAppBar({@required String title, @required bool showBackButton, Widget bottomWidget, double bottomWidgetHeight}) {
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
        child: bottomWidget == null
            ? Container(
                color: appBorderColor(),
                height: 1.0,
              )
            : bottomWidget,
        preferredSize: Size.fromHeight(bottomWidgetHeight == null ? 4.0 : bottomWidgetHeight),
      ),
    );
  }

  Widget basicActionAppBar(
      {@required String title,
      @required bool showBackButton,
      @required actionWidget,
      Widget bottomWidget,
      double bottomWidgetHeight,
      VoidCallback onPressedBack}) {
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
      leading: showBackButton
          ? BackButton(
              color: appIconColor(),
              onPressed: onPressedBack != null ? onPressedBack : null,
            )
          : Container(),
      actions: [
        actionWidget,
      ],
      bottom: PreferredSize(
        child: bottomWidget == null
            ? Container(
                color: appBorderColor(),
                height: 1.0,
              )
            : bottomWidget,
        preferredSize: Size.fromHeight(bottomWidgetHeight == null ? 4.0 : bottomWidgetHeight),
      ),
    );
  }
}
