import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';

import 'under_maintenance_error_view_model.dart';

class UnderMaintenanceErrorView extends StatelessWidget {
  final VoidCallback tryAgainAction;
  UnderMaintenanceErrorView({required this.tryAgainAction});
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UnderMaintenanceErrorViewModel>.nonReactive(
      disposeViewModel: true,
      viewModelBuilder: () => UnderMaintenanceErrorViewModel(),
      builder: (context, model, child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: screenHeight(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Servers Are Currently Under Maintenance. \n Please Try Again Later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appFontColor(),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
              elevation: 1,
              text: 'Try Again',
              textColor: appFontColor(),
              backgroundColor: appBackgroundColor(),
              isBusy: false,
              height: 50,
              width: screenWidth(context),
              onPressed: tryAgainAction,
            ),
          ],
        ),
      ),
    );
  }
}
