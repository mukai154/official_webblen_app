import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';

import 'post_author_bottom_sheet_model.dart';

class PostAuthorBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const PostAuthorBottomSheet({
    Key key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PostAuthorBottomSheetModel>.nonReactive(
      viewModelBuilder: () => PostAuthorBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              onPressed: () => completer(SheetResponse(responseData: "edit")),
              text: "Edit",
              textSize: 16,
              textColor: appFontColor(),
              height: 45,
              width: screenWidth(context),
              backgroundColor: appBackgroundColor(),
              elevation: 1.0,
              isBusy: false,
            ),
            verticalSpaceSmall,
            CustomButton(
              onPressed: () => completer(SheetResponse(responseData: "share")),
              text: "Share (disabled)",
              textSize: 16,
              textColor: appInActiveColorAlt(),
              height: 45,
              width: screenWidth(context),
              backgroundColor: appBackgroundColor(),
              elevation: 1.0,
              isBusy: false,
            ),
            verticalSpaceSmall,
            CustomButton(
              onPressed: () => completer(SheetResponse(responseData: "report")),
              text: "Delete",
              textSize: 16,
              textColor: appDestructiveColor(),
              height: 45,
              width: screenWidth(context),
              backgroundColor: appBackgroundColor(),
              elevation: 1.0,
              isBusy: false,
            ),
          ],
        ),
      ),
    );
  }
}
