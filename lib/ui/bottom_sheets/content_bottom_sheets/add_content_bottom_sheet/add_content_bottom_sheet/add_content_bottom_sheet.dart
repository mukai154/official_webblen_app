import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

import 'add_content_bottom_sheet_model.dart';

class AddContentBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const AddContentBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddContentBottomSheetModel>.nonReactive(
      viewModelBuilder: () => AddContentBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              text: "Add New",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CustomVerticalIconButton(
                      icon: Icon(
                        FontAwesomeIcons.edit,
                        size: 16,
                      ),
                      backgroundColor: appBorderColorAlt(),
                      text: "Post",
                      height: 70,
                      width: 70,
                      onTap: () => completer!(SheetResponse(responseData: "new post")),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomVerticalIconButton(
                      icon: Icon(
                        FontAwesomeIcons.video,
                        size: 16,
                      ),
                      backgroundColor: appBorderColorAlt(),
                      text: "Stream",
                      height: 70,
                      width: 70,
                      onTap: () => completer!(SheetResponse(responseData: "new stream")),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomVerticalIconButton(
                      icon: Icon(
                        FontAwesomeIcons.calendar,
                        size: 16,
                      ),
                      backgroundColor: appBorderColorAlt(),
                      text: "Event",
                      height: 70,
                      width: 70,
                      onTap: () => completer!(SheetResponse(responseData: "new event")),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomVerticalIconButton(
                      icon: Icon(
                        FontAwesomeIcons.bolt,
                        size: 16,
                      ),
                      backgroundColor: appBorderColorAlt(),
                      text: "Flash Event",
                      height: 70,
                      width: 70,
                      onTap: () => completer!(SheetResponse(responseData: "new flash event")),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
