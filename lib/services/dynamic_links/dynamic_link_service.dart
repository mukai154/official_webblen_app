import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class DynamicLinkService {
  SnackbarService _snackbarService = locator<SnackbarService>();
  NavigationService _navigationService = locator<NavigationService>();

  String webblenShareContentPrefix = 'https://app.webblen.io/shared_link';
  String androidPackageName = 'com.webblen.events.webblen';
  String iosBundleID = 'com.webblen.events';
  String iosAppStoreID = '1196159158';

  Future<String> createProfileLink({required WebblenUser user}) async {
    //set uri
    Uri postURI = Uri.parse('https://app.webblen.io/profiles/profile?id=${user.id}');

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
        title: "Checkout ${user.username}'s account on Webblen",
        description: user.bio != null ? user.bio : null,
        imageUrl: user.profilePicURL != null ? Uri.parse(user.profilePicURL!) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future<String> createPostLink({required String? authorUsername, required WebblenPost post}) async {
    //set uri
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
        title: "Checkout $authorUsername's post on Webblen",
        description: post.body!.length > 200 ? post.body!.substring(0, 190) + "..." : post.body,
        imageUrl: post.imageURL != null ? Uri.parse(post.imageURL!) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future<String> createEventLink({required String? authorUsername, required WebblenEvent event}) async {
    //set uri
    Uri postURI = Uri.parse('https://app.webblen.io/events/event?id=${event.id}');

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
        title: "Checkout ${event.title} hosted by @$authorUsername on Webblen",
        description: event.description!.length > 200 ? event.description!.substring(0, 190) + "..." : event.description,
        imageUrl: event.imageURL != null ? Uri.parse(event.imageURL!) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future<String> createLiveStreamLink({required String? authorUsername, required WebblenLiveStream stream}) async {
    //set uri
    Uri postURI = Uri.parse('https://app.webblen.io/streams/stream?id=${stream.id}');

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
        title: "Checkout this video stream: ${stream.title}\nhosted by @$authorUsername on Webblen",
        description: stream.description!.length > 200 ? stream.description!.substring(0, 190) + "..." : stream.description,
        imageUrl: stream.imageURL != null ? Uri.parse(stream.imageURL!) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future handleDynamicLinks() async {
    // get dynamic link on app open
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDynamicLink(data);

    // get dynamic link if app already running
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData? linkData) async {
      _handleDynamicLink(linkData);
    }, onError: (OnLinkErrorException err) async {
      _snackbarService.showSnackbar(
        title: 'App Link Error',
        message: err.message!,
        duration: Duration(seconds: 5),
      );
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData? linkData) {
    CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
    final Uri? link = linkData?.link;
    if (link != null) {
      print(link);
      String? id = link.queryParameters['id'];
      if (id != null) {
        if (link.pathSegments.contains('profile')) {
          _customNavigationService.navigateToUserView(id);
        } else if (link.pathSegments.contains('post')) {
          _customNavigationService.navigateToPostView(id);
        } else if (link.pathSegments.contains('event')) {
          _customNavigationService.navigateToEventView(id);
        } else if (link.pathSegments.contains('stream')) {
          _customNavigationService.navigateToLiveStreamView(id);
        } else if (link.pathSegments.contains('ticket')) {
          _customNavigationService.navigateToTicketView(id);
        } else {
          _snackbarService.showSnackbar(
            title: 'App Link Error',
            message: 'There was an issues loading the desired link',
            duration: Duration(seconds: 5),
          );
        }
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
