import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/base/init_error_views/update_required/update_required_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';

class UpdateRequiredView extends StatelessWidget {
  final VoidCallback tryAgainAction;
  UpdateRequiredView({required this.tryAgainAction});
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UpdateRequiredViewModel>.nonReactive(
      disposeViewModel: true,
      viewModelBuilder: () => UpdateRequiredViewModel(),
      builder: (context, model, child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: screenHeight(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Update Required",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appFontColor(),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Please Update Webblen to Continue",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appFontColor(),
                fontWeight: FontWeight.w500,
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
            SizedBox(height: 4),
            CustomButton(
              elevation: 1,
              text: 'Update Webblen',
              textColor: appFontColor(),
              backgroundColor: appBackgroundColor(),
              isBusy: false,
              height: 50,
              width: screenWidth(context),
              onPressed: () => model.updateApp(),
            ),
          ],
        ),
      ),
    );
  }
}
