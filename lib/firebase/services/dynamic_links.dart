import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinks {
  Future<String> createDynamicLink({String contentType, String id, String title, String description, String imageURL}) async {
    Uri uri;
    if (contentType == 'post') {
      uri = Uri.parse('https://app.webblen.io/#/post?id=$id');
    } else if (contentType == 'event') {
      uri = Uri.parse('https://app.webblen.io/#/event?id=$id');
    } else if (contentType == 'user') {
      uri = Uri.parse('https://app.webblen.io/#/user?id=$id');
    }

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://webblen.page.link',
      link: uri,
      androidParameters: AndroidParameters(
        packageName: 'com.webblen.events.webblen',
        minimumVersion: 125,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.webblen.events',
        minimumVersion: '1.0.1',
        appStoreId: '1196159158',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        imageUrl: Uri.parse(imageURL),
        description: description,
      ),
//      googleAnalyticsParameters: GoogleAnalyticsParameters(
//        campaign: 'example-promo',
//        medium: 'social',
//        source: 'orkut',
//      ),
//      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
//        providerToken: '123456',
//        campaignToken: 'example-promo',
//      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    return shortDynamicLink.shortUrl.toString();
  }
}
