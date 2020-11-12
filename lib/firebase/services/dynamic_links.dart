import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinks {
  Future<String> createDynamicLink({String linkType, String id, String title, String description, String imageURL}) async {
    Uri uri;
    if (linkType == 'post') {
      uri = Uri.parse('https://app.webblen.io/#/post?id=$id');
    } else if (linkType == 'event') {
      uri = Uri.parse('https://app.webblen.io/#/event?id=$id');
    } else if (linkType == 'user') {
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
        imageUrl: Uri.dataFromString(imageURL),
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

    final Uri dynamicLink = await parameters.buildUrl();
    return dynamicLink.toString();
  }

  Future<Map<String, dynamic>> handleDynamicLinks() async {
    Map<String, dynamic> data = {};
    final PendingDynamicLinkData linkData = await FirebaseDynamicLinks.instance.getInitialLink();
    handleLink(linkData);
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        handleLink(dynamicLink);
      },
      onError: (OnLinkErrorException e) async {
        print('Link Failed: ${e.message}');
      },
    );
    return data;
  }

  void handleLink(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');
    }
  }
}
