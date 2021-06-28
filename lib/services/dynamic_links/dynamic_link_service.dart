import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/mini_video_player/reactive_mini_video_player_service.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view_model.dart';

class DynamicLinkService {
  SnackbarService _snackbarService = locator<SnackbarService>();

  String webblenShareContentPrefix = 'https://app.webblen.io/shared_link';
  String androidPackageName = 'com.webblen.events.webblen';
  String iosBundleID = 'com.webblen.events';
  String iosAppStoreID = '1196159158';

  Future<String> createProfileLink({required WebblenUser user}) async {
    //set uri
    Uri uri = Uri.parse('https://app.webblen.io/profiles/${user.id}');

    //set dynamic link params
    final DynamicLinkParameters params = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: webblenShareContentPrefix,
      link: uri,
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        fallbackUrl: uri,
      ),
      iosParameters: IosParameters(
        bundleId: iosBundleID,
        appStoreId: iosAppStoreID,
        fallbackUrl: uri,
        ipadFallbackUrl: uri,
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
    Uri uri = Uri.parse('https://app.webblen.io/posts/${post.id}');

    //set dynamic link params
    final DynamicLinkParameters params = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      uriPrefix: webblenShareContentPrefix,
      link: uri,
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        fallbackUrl: uri,
      ),
      iosParameters: IosParameters(
        bundleId: iosBundleID,
        appStoreId: iosAppStoreID,
        fallbackUrl: uri,
        ipadFallbackUrl: uri,
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
    Uri uri = Uri.parse('https://app.webblen.io/events/${event.id}');

    //set dynamic link params
    final DynamicLinkParameters params = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      uriPrefix: webblenShareContentPrefix,
      link: uri,
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        fallbackUrl: uri,
      ),
      iosParameters: IosParameters(
        bundleId: iosBundleID,
        appStoreId: iosAppStoreID,
        fallbackUrl: uri,
        ipadFallbackUrl: uri,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Checkout ${event.title} hosted by $authorUsername on Webblen",
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
    Uri uri = Uri.parse('https://app.webblen.io/streams/${stream.id}');

    //set dynamic link params
    final DynamicLinkParameters params = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      uriPrefix: webblenShareContentPrefix,
      link: uri,
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        fallbackUrl: uri,
      ),
      iosParameters: IosParameters(
        bundleId: iosBundleID,
        appStoreId: iosAppStoreID,
        fallbackUrl: uri,
        ipadFallbackUrl: uri,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Checkout this video stream: ${stream.title}\nhosted by $authorUsername on Webblen",
        description: stream.description!.length > 200 ? stream.description!.substring(0, 190) + "..." : stream.description,
        imageUrl: stream.imageURL != null ? Uri.parse(stream.imageURL!) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future<String> createVideoLink({required String? authorUsername, required WebblenLiveStream stream}) async {
    //set uri
    Uri uri = Uri.parse('https://app.webblen.io/video/${stream.id}');

    //set dynamic link params
    final DynamicLinkParameters params = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      uriPrefix: webblenShareContentPrefix,
      link: uri,
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      androidParameters: AndroidParameters(
        packageName: androidPackageName,
        fallbackUrl: uri,
      ),
      iosParameters: IosParameters(
        bundleId: iosBundleID,
        appStoreId: iosAppStoreID,
        fallbackUrl: uri,
        ipadFallbackUrl: uri,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Checkout this video: ${stream.title}\nby $authorUsername on Webblen",
        description: stream.description!.length > 200 ? stream.description!.substring(0, 190) + "..." : stream.description,
        imageUrl: stream.imageURL != null ? Uri.parse(stream.imageURL!) : null,
      ),
    );

    ShortDynamicLink shortDynamicLink = await params.buildShortLink();
    Uri dynamicURL = shortDynamicLink.shortUrl;

    return dynamicURL.toString();
  }

  Future handleVariousAppLinks() async {
    AppLinks(
      onAppLink: (uri, error) {
        if (uri.toString().contains('shared_link')) {
          handleDynamicLinks(uri);
        } else {
          _handleAppLink(uri);
        }
      },
    );
  }

  Future handleDynamicLinks(Uri link) async {
    // get dynamic link on app open
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getDynamicLink(link);
    print(data);
    _handleDynamicLink(data);

    // get dynamic link if app already running
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData? linkData) async {
      _handleDynamicLink(linkData);
    }, onError: (OnLinkErrorException err) async {
      _snackbarService.showSnackbar(
        title: 'App Link Error',
        message: 'There was an issues loading the desired link',
        duration: Duration(seconds: 5),
      );
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData? linkData) {
    final Uri? link = linkData?.link;
    _handleAppLink(link);
  }

  void _handleAppLink(Uri? link) async {
    CustomNavigationService _customNavigationService = locator<CustomNavigationService>();

    if (link != null) {
      String stringifiedLink = link.toString();
      int index = stringifiedLink.lastIndexOf("/");
      String id = stringifiedLink.substring(index + 1, stringifiedLink.length);
      print(id);
      if (stringifiedLink.contains('profile')) {
        _customNavigationService.navigateToUserView(id);
      } else if (stringifiedLink.contains('post')) {
        _customNavigationService.navigateToPostView(id);
      } else if (stringifiedLink.contains('event')) {
        _customNavigationService.navigateToEventView(id);
      } else if (stringifiedLink.contains('stream')) {
        _customNavigationService.navigateToLiveStreamView(id);
      } else if (stringifiedLink.contains('my_tickets')) {
        _customNavigationService.navigateToMyTicketsView();
      } else if (stringifiedLink.contains('video')) {
        ///OPENS VIDEO or RECORDED STREAM
        LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
        ReactiveMiniVideoPlayerService _reactiveMiniVideoPlayerService = locator<ReactiveMiniVideoPlayerService>();
        UserDataService _userDataService = locator<UserDataService>();
        MiniVideoPlayerViewModel _miniVideoPlayerViewModel = locator<MiniVideoPlayerViewModel>();
        WebblenLiveStream stream = await _liveStreamDataService.getStreamByID(id);

        if (stream.hostID != null) {
          WebblenUser host = await _userDataService.getWebblenUserByID(stream.hostID);
          _reactiveMiniVideoPlayerService.updateSelectedStream(stream);
          _reactiveMiniVideoPlayerService.updateSelectedStreamCreator(host.username!);
          _miniVideoPlayerViewModel.expandMiniPlayer();
        }
      } else if (stringifiedLink.contains('ticket') && !stringifiedLink.contains('my_tickets')) {
        _customNavigationService.navigateToTicketView(id);
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
