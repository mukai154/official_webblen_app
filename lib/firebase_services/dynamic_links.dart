import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinks {
  Future<Uri> createDynamicLink(String eventKey, String eventTitle, String eventDesc, String imageURL) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://webblenevents.page.link',
      link: Uri.parse('https://app.webblen.io/#/event?id=$eventKey'),
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
        title: eventTitle,
        imageUrl: Uri.dataFromString(imageURL),
        description: "Learn More About the  Event: $eventTitle on Webblen",
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
    final Uri shortUrl = shortDynamicLink.shortUrl;

    return shortUrl;
  }
}
