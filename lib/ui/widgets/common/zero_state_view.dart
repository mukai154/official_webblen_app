import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';

import 'buttons/custom_button.dart';
import 'custom_text.dart';

class ZeroStateView extends StatelessWidget {
  final String imageAssetName;
  final String header;
  final String subHeader;
  final String mainActionButtonTitle;
  final VoidCallback mainAction;
  final String secondaryActionButtonTitle;
  final VoidCallback secondaryAction;

  ZeroStateView({
    @required this.imageAssetName,
    @required this.header,
    @required this.subHeader,
    @required this.mainActionButtonTitle,
    @required this.mainAction,
    @required this.secondaryActionButtonTitle,
    @required this.secondaryAction,
  });

  Widget customImage() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Image.asset(
          'assets/images/$imageAssetName.png',
          height: 200,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customImage(),
          verticalSpaceMedium,
          CustomText(text: header, fontSize: 18, fontWeight: FontWeight.bold, color: appFontColor()),
          verticalSpaceTiny,
          CustomText(text: subHeader, fontSize: 14, fontWeight: FontWeight.w400, color: appFontColor()),
          verticalSpaceMedium,
          mainAction == null
              ? Container()
              : CustomButton(
                  onPressed: mainAction,
                  text: mainActionButtonTitle,
                  textSize: 14,
                  textColor: appFontColor(),
                  height: 40,
                  width: 300,
                  backgroundColor: appButtonColor(),
                  isBusy: false,
                  elevation: 2,
                ),
          verticalSpaceMedium,
          secondaryAction == null
              ? Container()
              : CustomFlatButton(
                  onTap: secondaryAction,
                  fontColor: appTextButtonColor(),
                  fontSize: 14,
                  text: secondaryActionButtonTitle,
                  textAlign: TextAlign.center,
                  showBottomBorder: false),
        ],
      ),
    );
  }
}
