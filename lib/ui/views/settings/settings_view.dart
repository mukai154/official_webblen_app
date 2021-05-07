import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/views/settings/settings_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
      viewModelBuilder: () => SettingsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Settings",
          showBackButton: true,
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ListView(
            children: [
              CustomSwitchButton(
                onTap: () => model.toggleDarkMode(),
                fontColor: appFontColor(),
                fontSize: 16,
                text: "Dark Mode",
                isActive: model.isDarkMode(),
                showBottomBorder: true,
              ),
              CustomFlatButton(
                onTap: () => model.getHelpFAQ(),
                fontColor: appFontColor(),
                fontSize: 16,
                text: "Help/FAQ",
                showBottomBorder: true,
                textAlign: TextAlign.left,
              ),
              CustomFlatButton(
                onTap: () => model.signOut(),
                fontColor: Colors.red,
                fontSize: 16,
                text: "Log Out",
                showBottomBorder: true,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
