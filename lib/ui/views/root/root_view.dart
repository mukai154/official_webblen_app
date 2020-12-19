import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';

import 'root_view_model.dart';

class RootView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(isDarkMode() ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    return ViewModelBuilder<RootViewModel>.reactive(
      viewModelBuilder: () => RootViewModel(),
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: appBackgroundColor(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(
                //   height: 120,
                //   child: Image.asset(
                //     model.themeService.isDarkMode ? 'assets/images/webblen_logo_light.png' : 'assets/images/webblen_logo_dark.png',
                //   ),
                // ),
                // SizedBox(height: 32.0),
                // CustomCircleProgressIndicator(
                //   color: model.themeService.isDarkMode ? Colors.white54 : Colors.black38,
                //   size: 30,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
