import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';

import 'content_author_bottom_sheet_model.dart';

class ContentAuthorBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const ContentAuthorBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ContentAuthorBottomSheetModel>.nonReactive(
      viewModelBuilder: () => ContentAuthorBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //can check in attendees
            request!.customData != null && request!.customData['checkInAttendees']
                ? CustomButton(
                    onPressed: () => completer!(SheetResponse(responseData: "check in")),
                    text: "Check In Attendees",
                    textSize: 16,
                    textColor: appFontColor(),
                    height: 45,
                    width: screenWidth(context),
                    backgroundColor: appBackgroundColor(),
                    elevation: 1.0,
                    isBusy: false,
                  )
                : Container(),
            request!.customData != null && request!.customData['checkInAttendees'] ? verticalSpaceSmall : Container(),

            //can publish recording
            request!.customData != null && request!.customData['canPublishRecording']
                ? CustomButton(
                    onPressed: () => completer!(SheetResponse(responseData: "publishRecording")),
                    text: "Publish Recording",
                    textSize: 16,
                    textColor: appFontColor(),
                    height: 45,
                    width: screenWidth(context),
                    backgroundColor: appBackgroundColor(),
                    elevation: 1.0,
                    isBusy: false,
                  )
                : Container(),
            request!.customData != null && request!.customData['canPublishRecording'] ? verticalSpaceSmall : Container(),

            //can edit
            request!.customData != null && request!.customData['availableForEditing']
                ? CustomButton(
                    onPressed: () => completer!(SheetResponse(responseData: "edit")),
                    text: "Edit",
                    textSize: 16,
                    textColor: appFontColor(),
                    height: 45,
                    width: screenWidth(context),
                    backgroundColor: appBackgroundColor(),
                    elevation: 1.0,
                    isBusy: false,
                  )
                : Container(),
            request!.customData != null && request!.customData['availableForEditing'] ? verticalSpaceSmall : Container(),

            //can duplicate
            request!.customData != null && request!.customData['canDuplicate']
                ? CustomButton(
                    onPressed: () => completer!(SheetResponse(responseData: "duplicate")),
                    text: "Duplicate",
                    textSize: 16,
                    textColor: appFontColor(),
                    height: 45,
                    width: screenWidth(context),
                    backgroundColor: appBackgroundColor(),
                    elevation: 1.0,
                    isBusy: false,
                  )
                : Container(),
            request!.customData != null && request!.customData['canDuplicate'] ? verticalSpaceSmall : Container(),

            //can share
            CustomButton(
              onPressed: () => completer!(SheetResponse(responseData: "share")),
              text: "Share",
              textSize: 16,
              textColor: appFontColor(),
              height: 45,
              width: screenWidth(context),
              backgroundColor: appBackgroundColor(),
              elevation: 1.0,
              isBusy: false,
            ),
            verticalSpaceSmall,

            //can delete
            CustomButton(
              onPressed: () => completer!(SheetResponse(responseData: "delete")),
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
