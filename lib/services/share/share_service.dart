import 'package:share/share.dart';

class ShareService {
  shareLink(String url) {
    Share.share(url);
  }
}
