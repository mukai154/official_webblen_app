import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class PayoutMethodBlockView extends StatelessWidget {
  final String header;
  final String subHeader;
  final VoidCallback updateAction;
  final bool isSetUp;

  PayoutMethodBlockView({required this.header, required this.subHeader, required this.updateAction, required this.isSetUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45, width: 0.3),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomText(
                  text: header,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                  textAlign: TextAlign.left,
                ),
                GestureDetector(
                  onTap: updateAction,
                  child: CustomText(
                    text: isSetUp ? "Update" : "Set Up",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSetUp ? appActiveColor() : appInActiveColor(),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: CustomText(
                    text: subHeader,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: appFontColor(),
                    textAlign: TextAlign.left,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
