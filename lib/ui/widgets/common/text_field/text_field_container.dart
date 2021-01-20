import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  TextFieldContainer({this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height != null ? height : null,
      width: width != null ? width : null,
      padding: EdgeInsets.only(left: 8.0),
      decoration: BoxDecoration(
        color: appTextFieldContainerColor(),
        border: Border.all(width: 1.0, color: appBorderColorAlt()),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: child,
    );
  }
}
