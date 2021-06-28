import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

import 'positive_confirmation_bottom_sheet_model.dart';

class PositiveConfirmationBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const PositiveConfirmationBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PositiveConfirmationBottomSheetModel>.nonReactive(
      viewModelBuilder: () => PositiveConfirmationBottomSheetModel(),
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
              text: request!.title,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
              textAlign: TextAlign.center,
            ),
            verticalSpaceTiny,
            CustomText(
              text: request!.description,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: appFontColorAlt(),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            CustomButton(
              onPressed: () => completer!(SheetResponse(responseData: "confirmed")),
              text: request!.mainButtonTitle,
              textSize: 16,
              textColor: Colors.white,
              height: 40,
              width: screenWidth(context),
              backgroundColor: appConfirmationColor(),
              elevation: 1.0,
              isBusy: false,
            ),
            verticalSpaceSmall,
            CustomButton(
              onPressed: () => completer!(SheetResponse(responseData: "cancelled")),
              text: request!.secondaryButtonTitle,
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
