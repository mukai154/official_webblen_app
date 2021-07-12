import 'package:stacked/stacked.dart';

class HomeFeedModel extends BaseViewModel {
  ///DATA
  String contentType = "Posts, Streams, and Events";

  updateContentType(String val) {
    contentType = val;
    notifyListeners();
  }
}
