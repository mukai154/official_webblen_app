import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'new_content_confirmation_bottom_sheet_model.dart';

class NewContentConfirmationBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const NewContentConfirmationBottomSheet({
    Key key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewContentConfirmationBottomSheetModel>.reactive(
      viewModelBuilder: () => NewContentConfirmationBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              text: request.title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
              textAlign: TextAlign.left,
            ),
            verticalSpaceTiny,
            CustomText(
              text: request.description,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: appFontColorAlt(),
              textAlign: TextAlign.left,
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Available Balance:",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                  textAlign: TextAlign.left,
                ),
                model.webblenBalance == null
                    ? CustomCircleProgressIndicator(size: 10, color: appActiveColor())
                    : CustomText(
                        text: "${model.webblenBalance.toStringAsFixed(2)} WBLN",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appFontColor(),
                        textAlign: TextAlign.right,
                      ),
              ],
            ),
            verticalSpaceSmall,
            request.customData['promo'] != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Bonus:",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                      ),
                      CustomText(
                        text: "+${request.customData['promo'].toStringAsFixed(2)} WBLN",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: model.webblenBalance == null ? Colors.transparent : appConfirmationColor(),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  )
                : Container(),
            request.customData['promo'] != null ? verticalSpaceSmall : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Cost:",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                  textAlign: TextAlign.left,
                ),
                CustomText(
                  text: "-${request.customData['fee'].toStringAsFixed(2)} WBLN",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: model.webblenBalance == null ? Colors.transparent : appDestructiveColor(),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            verticalSpaceMedium,
            Divider(
              color: appBorderColor(),
              indent: 8.0,
              endIndent: 8.0,
              thickness: 1.0,
              height: 4,
            ),
            verticalSpaceMedium,
            model.webblenBalance == null
                ? Container(height: 15)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        child: Image.asset(
                          'assets/images/webblen_coin.png',
                        ),
                      ),
                      horizontalSpaceSmall,
                      CustomText(
                        text: request.customData['promo'] == null
                            ? "${(model.webblenBalance - request.customData['fee']).toStringAsFixed(2)} WBLN"
                            : "${(model.webblenBalance + request.customData['promo'] - request.customData['fee']).toStringAsFixed(2)} WBLN",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appFontColor(),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
            verticalSpaceLarge,
            CustomButton(
              onPressed: model.webblenBalance == null
                  ? null
                  : request.customData['promo'] != null && (model.webblenBalance + request.customData['promo']) < request.customData['fee'] ||
                          request.customData['promo'] == null && model.webblenBalance < request.customData['fee']
                      ? () => completer(SheetResponse(responseData: "insufficient funds"))
                      : () => completer(SheetResponse(responseData: "confirmed")),
              text: model.webblenBalance == null ? "Calculating Total..." : request.mainButtonTitle,
              textSize: 16,
              textColor: model.webblenBalance == null ? appFontColorAlt() : Colors.white,
              height: 40,
              width: screenWidth(context),
              backgroundColor: model.webblenBalance == null ? appButtonColor() : appConfirmationColor(),
              elevation: 1.0,
              isBusy: false,
            ),
            verticalSpaceSmall,
            CustomButton(
              onPressed: () => completer(SheetResponse(responseData: "cancelled")),
              text: request.secondaryButtonTitle,
              textSize: 16,
              textColor: appFontColor(),
              height: 40,
              width: screenWidth(context),
              backgroundColor: appButtonColorAlt(),
              elevation: 1.0,
              isBusy: false,
            ),
          ],
        ),
      ),
    );
  }
}
