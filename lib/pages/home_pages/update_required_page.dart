import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class UpdateRequiredPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(
            context: context,
            text: 'Update Required',
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          Text(
            'Please Update Your Current Version of Webblen to Continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16.0),
          CustomColorButton(
            text: 'Update Now',
            textColor: Colors.black,
            backgroundColor: Colors.white,
            height: 35.0,
            width: 200.0,
            onPressed: () {
              String url;
              if (Platform.isIOS) {
                url = 'https://apps.apple.com/us/app/webblen/id1196159158';
              } else {
                url = 'https://play.google.com/store/apps/details?id=com.webblen.events.webblen&hl=en_US';
              }
              OpenUrl().launchInWebViewOrVC(context, url);
            },
          ),
        ],
      ),
    );
  }
}
