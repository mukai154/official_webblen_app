import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class CustomBottomActionBar extends StatelessWidget {
  final String header;
  final String subHeader;
  final String buttonTitle;
  final VoidCallback buttonAction;

  CustomBottomActionBar({required this.header, required this.subHeader, required this.buttonTitle, required this.buttonAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: appBackgroundColor(),
        border: Border(
          top: BorderSide(
            color: appBorderColor(),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, bottom: 18.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomText(
                  text: header,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: subHeader,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: appFontColor(),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomButton(
                  onPressed: buttonAction,
                  text: buttonTitle,
                  textSize: 16,
                  textColor: Colors.white,
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: appActiveColor(),
                  elevation: 1.0,
                  isBusy: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
