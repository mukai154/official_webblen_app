import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/bottom_sheets/user_options_bottom_sheets/user_options_bottom_sheet/user_options_bottom_sheet_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';

class UserOptionsBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const UserOptionsBottomSheet({
    Key key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserOptionsBottomSheetModel>.nonReactive(
      viewModelBuilder: () => UserOptionsBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomIconButton(
              icon: Icon(
                FontAwesomeIcons.link,
                size: 16,
              ),
              height: 45,
              onPressed: () => completer(SheetResponse(responseData: "share profile")),
              backgroundColor: appButtonColor(),
              elevation: 1,
              text: "Share Profile",
              textColor: appFontColor(),
              centerContent: false,
            ),
            // verticalSpaceSmall,
            // CustomIconButton(
            //   icon: Icon(
            //     FontAwesomeIcons.paperPlane,
            //     size: 16,
            //   ),
            //   height: 45,
            //   onPressed: () => completer(SheetResponse(responseData: "message")),
            //   backgroundColor: appButtonColor(),
            //   elevation: 1,
            //   text: "Message",
            //   textColor: appFontColor(),
            //   centerContent: false,
            // ),
            // verticalSpaceSmall,
            // CustomIconButton(
            //   icon: Icon(
            //     FontAwesomeIcons.ban,
            //     size: 16,
            //   ),
            //   height: 45,
            //   onPressed: () => completer(SheetResponse(responseData: "block")),
            //   backgroundColor: appButtonColor(),
            //   elevation: 1,
            //   text: "Block",
            //   textColor: appFontColor(),
            //   centerContent: false,
            // ),
            // verticalSpaceSmall,
            // CustomIconButton(
            //   icon: Icon(
            //     FontAwesomeIcons.flag,
            //     size: 16,
            //   ),
            //   height: 45,
            //   onPressed: () => completer(SheetResponse(responseData: "report")),
            //   backgroundColor: appButtonColor(),
            //   elevation: 1,
            //   text: "Report",
            //   textColor: appFontColor(),
            //   centerContent: false,
            // ),
          ],
        ),
      ),
    );
  }
}
