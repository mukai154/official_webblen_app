import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webblen/services_general/services_show_alert.dart';

class OpenUrl {
  bool isValidUrl(String url) {
    bool isValid = true;
    var urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    isValid = RegExp(urlPattern, caseSensitive: false).hasMatch(url);
    return isValid;
  }

  openMaps(BuildContext context, String lat, String lon) async {
    String mapURL;
    if (Platform.isAndroid) {
      mapURL = 'geo:' + lat + "," + lon;
    } else if (Platform.isIOS) {
      mapURL = 'http://maps.apple.com/?ll=' + lat + "," + lon;
    }
    if (await canLaunch(mapURL)) {
      await launch(mapURL);
    } else {
      ShowAlertDialogService().showFailureDialog(
        context,
        "Map Error",
        "There was an issue launching maps",
      );
    }
  }

  launchInWebViewOrVC(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        //forceWebView: true,
        //statusBarBrightness: Brightness.light,
      );
    } else {
      ShowAlertDialogService().showFailureDialog(
        context,
        "URL Error",
        "There was an issue launching this url",
      );
    }
  }
}
