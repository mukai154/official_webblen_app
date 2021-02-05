import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';

import 'buttons/custom_button.dart';
import 'custom_text.dart';

class ZeroStateView extends StatelessWidget {
  final String imageAssetName;
  final double imageSize;
  final String header;
  final String subHeader;
  final String mainActionButtonTitle;
  final VoidCallback mainAction;
  final String secondaryActionButtonTitle;
  final VoidCallback secondaryAction;
  final VoidCallback refreshData;
  final ScrollController scrollController;

  ZeroStateView({
    @required this.imageAssetName,
    @required this.imageSize,
    @required this.header,
    @required this.subHeader,
    @required this.mainActionButtonTitle,
    @required this.mainAction,
    @required this.secondaryActionButtonTitle,
    @required this.secondaryAction,
    @required this.scrollController,
    @required this.refreshData,
  });

  Widget customImage() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Image.asset(
          'assets/images/$imageAssetName.png',
          height: imageSize,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  Widget body() {
    return LiquidPullToRefresh(
      onRefresh: refreshData,
      child: Center(
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          controller: scrollController,
          children: [
            imageAssetName == null ? Container() : customImage(),
            verticalSpaceSmall,
            CustomText(
              text: header,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
              textAlign: TextAlign.center,
            ),
            verticalSpaceTiny,
            CustomText(
              text: subHeader,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: appFontColor(),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            mainAction == null
                ? Container()
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: CustomButton(
                      onPressed: mainAction,
                      text: mainActionButtonTitle,
                      textSize: 14,
                      textColor: appFontColor(),
                      height: 40,
                      width: 300,
                      backgroundColor: appButtonColorAlt(),
                      isBusy: false,
                      elevation: 2,
                    ),
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
                    showBottomBorder: false,
                  ),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight(context),
      color: appBackgroundColor(),
      child: body(),
    );
  }
}
