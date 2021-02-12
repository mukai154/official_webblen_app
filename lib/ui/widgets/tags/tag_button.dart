import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class TagButton extends StatelessWidget {
  final VoidCallback onTap;
  final String tag;

  TagButton({@required this.onTap, @required this.tag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(right: 16),
          child: CustomText(
            text: "#$tag",
            color: appFontColorAlt(),
            fontSize: 14,
            textAlign: TextAlign.left,
            fontWeight: FontWeight.w500,
          ),
        ));
  }
}

class RemovableTagButton extends StatelessWidget {
  final VoidCallback onTap;
  final String tag;

  RemovableTagButton({@required this.onTap, @required this.tag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        elevation: 2.0,
        color: appBorderColorAlt(),
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.solidTimesCircle,
                  color: appFontColorAlt(),
                  size: 12,
                ),
                horizontalSpaceTiny,
                CustomText(
                  text: " #$tag",
                  color: appFontColorAlt(),
                  fontSize: 16,
                  textAlign: TextAlign.left,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
