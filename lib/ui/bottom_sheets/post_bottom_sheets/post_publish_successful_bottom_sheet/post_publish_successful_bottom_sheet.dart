import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

import 'post_publish_successful_bottom_sheet_model.dart';

class PostSuccessfulBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const PostSuccessfulBottomSheet({
    Key key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PostSuccessfulBottomSheetModel>.nonReactive(
      viewModelBuilder: () => PostSuccessfulBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpaceSmall,
            CustomText(
              text: "Post Published!",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
            ),
            verticalSpaceTiny,
            CustomText(
              text: "Don't Forget to Share it!",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: appFontColorAlt(),
            ),
            verticalSpaceMedium,
            CustomTextButton(
              onTap: null,
              text: "Share (disabled)",
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: appTextButtonColor(),
            ),
            verticalSpaceMedium,
            CustomTextButton(
              onTap: null,
              text: "Copy Link (disabled)",
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: appTextButtonColor(),
            ),
            verticalSpaceMedium,
            CustomButton(
              onPressed: () => completer(SheetResponse(responseData: "return")),
              text: "Done",
              textSize: 16,
              textColor: appFontColor(),
              height: 45,
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
