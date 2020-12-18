import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double textSize;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final bool isBusy;

  CustomButton({
    this.text,
    this.textSize,
    this.height,
    this.width,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation == null ? 2.0 : elevation,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: isBusy ? null : onPressed,
        child: Container(
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4.0),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: isBusy
                      ? CustomCircleProgressIndicator(size: height / 2, color: textColor)
                      : FittedBox(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: textSize != null ? textSize : 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          fit: BoxFit.scaleDown,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final double height;
  final double width;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;

  CustomIconButton({
    this.icon,
    this.text,
    this.height,
    this.width,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation == null ? 2.0 : elevation,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: onPressed,
        child: Container(
          height: height,
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              text != null
                  ? SizedBox(
                      width: 8.0,
                    )
                  : Container(),
              text != null
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaleFactor: 1.0,
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

class CustomFlatButton extends StatelessWidget {
  final String text;
  final Color fontColor;
  final double fontSize;
  final VoidCallback onTap;
  final bool showBottomBorder;
  CustomFlatButton({
    @required this.onTap,
    @required this.fontColor,
    @required this.fontSize,
    @required this.text,
    @required this.showBottomBorder,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: screenWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: showBottomBorder ? BorderSide(width: 0.5, color: appBorderColorAlt()) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSwitchButton extends StatelessWidget {
  final String text;
  final Color fontColor;
  final double fontSize;
  final VoidCallback onTap;
  final bool showBottomBorder;
  final bool isActive;

  CustomSwitchButton({
    @required this.onTap,
    @required this.fontColor,
    @required this.fontSize,
    @required this.text,
    @required this.isActive,
    @required this.showBottomBorder,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: screenWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: showBottomBorder ? BorderSide(width: 0.5, color: appBorderColorAlt()) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isActive ? 'On' : 'Off',
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
