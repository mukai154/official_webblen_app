import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class TagContainer extends StatelessWidget {
  final String tag;
  final double width;
  final Color color;
  TagContainer({this.tag, this.color, this.width});
  @override
  Widget build(BuildContext context) {
    return width == null
        ? Container(
            padding: EdgeInsets.all(2.0),
//            decoration: BoxDecoration(
//              borderRadius: BorderRadius.all(Radius.circular(8.0)),
//              border: Border.all(
//                color: CustomColors.electronBlue,
//                width: 2.0,
//              ),
//            ),
            child: CustomText(
              context: context,
              text: tag,
              textColor: color,
              textAlign: TextAlign.center,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          )
        : Container(
            width: width,
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(
                color: CustomColors.electronBlue,
                width: 2.0,
              ),
            ),
            child: CustomText(
              context: context,
              text: tag,
              textColor: CustomColors.electronBlue,
              textAlign: TextAlign.center,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          );
  }
}
