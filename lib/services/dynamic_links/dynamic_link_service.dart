import 'package:auto_route/auto_route.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/dynamic_link_type.dart';
import 'package:webblen/models/webblen_post.dart';

class DynamicLinkService {
  SnackbarService _snackbarService = locator<SnackbarService>();
  NavigationService _navigationService = locator<NavigationService>();

  String webblenShareContentPrefix = 'https://app.webblen.io/shared_link';
  String androidPackageName = 'com.webblen.events.webblen';
  String iosBundleID = 'com.webblen.events';
  String iosAppStoreID = '1196159158';

  Future<String> createPostLink({@required String postAuthorUsername, @required WebblenPost post}) async {
    //set post uri
    Uri postURI = Uri.parse('https://app.webblen.io/posts/post?id=${post.id}');

    //set dynamic link params
    final DynamicLinkParameters params = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      uriPrefix: webblenShareContentPrefix,
      link: postURI,
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
      ),
      iosParameters: IosParameters(
        bundleId: iosBundleID,
        appStoreId: iosAppStoreID,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Checkout @$postAuthorUsername's post on Webblen",
        description: post.body.length > 200 ? post.body.substring(0, 190) + "..." : post.body,
        imageUrl: post.imageURL != null ? Uri.parse(post.imageURL) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future handleDynamicLinks() async {
    // get dynamic link on app open
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDynamicLink(data);

    // get dynamic link if app already running
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData linkData) async {
      _handleDynamicLink(linkData);
    }, onError: (OnLinkErrorException err) async {
      _snackbarService.showSnackbar(
        title: 'App Link Error',
        message: err.message,
        duration: Duration(seconds: 5),
      );
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData linkData) {
    final Uri link = linkData?.link;
    if (link != null) {
      //print('_handleDeepLink | link: $link');
      DynamicLinkType linkType;
      String id = link.queryParameters['id'];

      if (link.pathSegments.contains('post')) {
        _navigationService.navigateTo(Routes.PostViewRoute, arguments: {'postID': id});
      } else if (link.pathSegments.contains('event')) {
        //_navigationService.navigateTo(Routes.PostViewRoute, arguments: {'postID': id});
      } else if (link.pathSegments.contains('stream')) {
        //_navigationService.navigateTo(Routes.PostViewRoute, arguments: {'postID': id});
      } else {
        _snackbarService.showSnackbar(
          title: 'App Link Error',
          message: 'There was an issues loading the desired link',
          duration: Duration(seconds: 5),
        );
      }
    }
  }
}
