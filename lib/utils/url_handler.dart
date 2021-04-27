import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class UrlHandler {
  DialogService? _dialogService = locator<DialogService>();

  launchInWebViewOrVC(String val) async {
    String url;
    //Check if url is an email
    if (isValidEmail(val)) {
      Uri emailURI = Uri(
        scheme: 'mailto',
        path: val,
      );
      url = emailURI.toString();
    } else {
      url = val;
    }
    //launch url
    if (await canLaunch(url)) {
      await launch(
        url,
        //forceSafariVC: true,
        //forceWebView: true,
        //statusBarBrightness: Brightness.light,
      );
    } else {
      _dialogService!.showDialog(
        title: "URL Error",
        description: "There was an issue launching this url",
        buttonTitle: "Ok",
      );
    }
  }
}
