import 'package:stacked/stacked.dart';
import 'package:webblen/utils/url_handler.dart';

class UpdateRequiredViewModel extends BaseViewModel {
  updateApp() {
    UrlHandler().launchInWebViewOrVC("https://l.linklyhq.com/l/8Z33");
  }
}
