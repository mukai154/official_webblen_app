import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webblen/app/locator.dart';

class UrlHandler {
  DialogService _dialogService = locator<DialogService>();

  bool isValidUrl(String url) {
    bool isValid = true;
    var urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    isValid = RegExp(urlPattern, caseSensitive: false).hasMatch(url);
    return isValid;
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
      _dialogService.showDialog(
        title: "URL Error",
        description: "There was an issue launching this url",
        buttonTitle: "Ok",
      );
    }
  }
}
