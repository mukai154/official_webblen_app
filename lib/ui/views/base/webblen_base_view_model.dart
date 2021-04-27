import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/enums/init_error_status.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/network_status.dart';

class WebblenBaseViewModel extends StreamViewModel<WebblenUser> {
  ///SERVICES
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  UserDataService? _userDataService = locator<UserDataService>();
  LocationService? _locationService = locator<LocationService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  PostDataService? _postDataService = locator<PostDataService>();
  EventDataService? _eventDataService = locator<EventDataService>();
  ShareService? _shareService = locator<ShareService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  DynamicLinkService? _dynamicLinkService = locator<DynamicLinkService>();
  LiveStreamDataService? _liveStreamDataService = locator<LiveStreamDataService>();

  ///INITIAL DATA
  InitErrorStatus initErrorStatus = InitErrorStatus.none;
  String? initialCityName;
  String? initialAreaCode;

  ///CURRENT USER
  String? uid;
  WebblenUser? user;

  ///TAB BAR STATE
  int _navBarIndex = 0;

  int get navBarIndex => _navBarIndex;

  void setNavBarIndex(int index) {
    _navBarIndex = index;
    notifyListeners();
  }

  ///STREAM USER DATA
  @override
  void onData(WebblenUser? data) {
    if (data != null) {
      if (user != data) {
        user = data;
        notifyListeners();
        setBusy(false);
      }
    }
  }

  @override
  Stream<WebblenUser> get stream => streamUser();

  Stream<WebblenUser> streamUser() async* {
    while (true) {
      if (uid == null) {
        yield null;
      }
      await Future.delayed(Duration(seconds: 1));
      WebblenUser? user = await _userDataService!.getWebblenUserByID(uid);
      yield user!;
    }
  }

  ///INITIALIZE DATA
  initialize() async {
    setBusy(true);
    uid = await _authService!.getCurrentUserID();
    notifyListeners();

    //check network status
    bool connectedToNetwork = await isConnectedToNetwork();
    if (!connectedToNetwork) {
      initErrorStatus = InitErrorStatus.network;
      notifyListeners();
      _snackbarService!.showSnackbar(
        title: 'Network Error',
        message: "There Was an Issue Connecting to the Internet",
        duration: Duration(seconds: 5),
      );
      setBusy(false);
      return;
    }

    //check gps permissions
    bool locationGranted = await getLocationDetails();
    if (!locationGranted) {
      initErrorStatus = InitErrorStatus.location;
      notifyListeners();
      _snackbarService!.showSnackbar(
        title: 'Location Error',
        message: "There Was an Issue Getting Your Location",
        duration: Duration(seconds: 5),
      );
      setBusy(false);
      return;
    }

    //if there are no errors, check for dynamic links
    initErrorStatus = InitErrorStatus.none;
    await _dynamicLinkService!.handleDynamicLinks();
    notifyListeners();
    setBusy(false);
  }

  ///NETWORK STATUS
  Future<bool> isConnectedToNetwork() async {
    bool isConnected = await NetworkStatus().isConnected();
    return isConnected;
  }

  ///LOCATION
  Future<bool> getLocationDetails() async {
    try {
      LocationData location = await (_locationService!.getCurrentLocation() as FutureOr<LocationData>);
      initialCityName = await _locationService!.getCityNameFromLatLon(location.latitude, location.longitude);
      initialAreaCode = await _locationService!.getZipFromLatLon(location.latitude, location.longitude);
      _userDataService!.updateLastSeenZipcode(id: uid, zip: initialAreaCode);
      notifyListeners();
    } catch (e) {
      return false;
    }
    return true;
  }

  ///BOTTOM SHEETS
  //bottom sheet for new post, event, or stream
  showAddContentOptions() async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.addContent,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "new post") {
        navigateToCreatePostPage();
      } else if (res == "new stream") {
        navigateToCreateStreamPage();
      } else if (res == "new event") {
        navigateToCreateEventPage();
      }
      notifyListeners();
    }
  }

  //bottom sheet for options one can take with post, event, or stream
  Future showContentOptions({required dynamic content}) async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      variant: content is WebblenLiveStream
          ? user!.id == content.hostID
              ? BottomSheetType.contentAuthorOptions
              : BottomSheetType.contentOptions
          : user!.id == content.authorID
              ? BottomSheetType.contentAuthorOptions
              : BottomSheetType.contentOptions,
    );

    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "edit") {
        if (content is WebblenPost) {
          //edit post
          // _navigationService.navigateTo(Routes.CreatePostViewRoute, arguments: {
          //   'id': content.id,
          // });
        } else if (content is WebblenEvent) {
          //edit event
          // _navigationService.navigateTo(Routes.CreateEventViewRoute, arguments: {
          //   'id': content.id,
          // });
        } else if (content is WebblenLiveStream) {
          //edit stream
          // _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute, arguments: {
          //   'id': content.id,
          // });
        }
      } else if (res == "share") {
        if (content is WebblenPost) {
          //share post link
          WebblenUser author = await (_userDataService!.getWebblenUserByID(content.authorID) as FutureOr<WebblenUser>);
          String url = await _dynamicLinkService!.createPostLink(authorUsername: author.username, post: content);
          _shareService!.shareLink(url);
        } else if (content is WebblenEvent) {
          //share event link
          WebblenUser author = await (_userDataService!.getWebblenUserByID(content.authorID) as FutureOr<WebblenUser>);
          String url = await _dynamicLinkService!.createEventLink(authorUsername: author.username, event: content);
          _shareService!.shareLink(url);
        } else if (content is WebblenLiveStream) {
          //share stream link
          WebblenUser author = await (_userDataService!.getWebblenUserByID(content.hostID) as FutureOr<WebblenUser>);
          String url = await _dynamicLinkService!.createLiveStreamLink(authorUsername: author.username, stream: content);
          _shareService!.shareLink(url);
        }
      } else if (res == "report") {
        if (content is WebblenPost) {
          //report post
          _postDataService!.reportPost(postID: content.id, reporterID: user!.id);
        } else if (content is WebblenEvent) {
          //report event
          _eventDataService!.reportEvent(eventID: content.id, reporterID: user!.id);
        } else if (content is WebblenLiveStream) {
          //report stream
          _liveStreamDataService!.reportStream(streamID: content.id, reporterID: user!.id);
        }
      } else if (res == "delete") {
        //delete content
        bool deletedContent = await deleteContentConfirmation(content: content);
        if (deletedContent) {
          return "deleted content";
        }
      }
    }
  }

  //bottom sheet for confirming the removal of a post, event, or stream
  Future<bool> deleteContentConfirmation({dynamic content}) async {
    if (content is WebblenPost) {
      var sheetResponse = await _bottomSheetService!.showCustomSheet(
        title: "Delete Post",
        description: "Are You Sure You Want to Delete this Post?",
        mainButtonTitle: "Delete Post",
        secondaryButtonTitle: "Cancel",
        barrierDismissible: true,
        variant: BottomSheetType.destructiveConfirmation,
      );
      if (sheetResponse != null) {
        String? res = sheetResponse.responseData;
        if (res == "confirmed") {
          _postDataService!.deletePost(post: content);
          _snackbarService!.showSnackbar(
            title: 'Post Deleted',
            message: "Your post has been deleted",
            duration: Duration(seconds: 5),
          );
          return true;
        }
      }
    } else if (content is WebblenEvent) {
      var sheetResponse = await _bottomSheetService!.showCustomSheet(
        title: "Delete Event",
        description: "Are You Sure You Want to Delete this Event?",
        mainButtonTitle: "Delete Event",
        secondaryButtonTitle: "Cancel",
        barrierDismissible: true,
        variant: BottomSheetType.destructiveConfirmation,
      );
      if (sheetResponse != null) {
        String? res = sheetResponse.responseData;
        if (res == "confirmed") {
          _eventDataService!.deleteEvent(event: content);
          _snackbarService!.showSnackbar(
            title: 'Event Deleted',
            message: "Your event has been deleted",
            duration: Duration(seconds: 5),
          );
          return true;
        }
      }
    } else if (content is WebblenLiveStream) {
      var sheetResponse = await _bottomSheetService!.showCustomSheet(
        title: "Delete Stream",
        description: "Are You Sure You Want to Delete this Stream?",
        mainButtonTitle: "Delete Post",
        secondaryButtonTitle: "Cancel",
        barrierDismissible: true,
        variant: BottomSheetType.destructiveConfirmation,
      );
      if (sheetResponse != null) {
        String? res = sheetResponse.responseData;
        if (res == "confirmed") {
          _liveStreamDataService!.deleteStream(stream: content);
          _snackbarService!.showSnackbar(
            title: 'Stream Deleted',
            message: "Your stream has been deleted",
            duration: Duration(seconds: 5),
          );
          return true;
        }
      }
    }
    return true;
  }

  ///NAVIGATION
  navigateToCreatePostPage() {
   // _navigationService.navigateTo(Routes.CreatePostViewRoute);
  }

  navigateToCreateEventPage() {
   //_navigationService.navigateTo(Routes.CreateEventViewRoute);
  }

  navigateToCreateStreamPage() {
    //_navigationService.navigateTo(Routes.CreateLiveStreamViewRoute);
  }

  ///PROMOS
  createPostWithPromo({required double? promo}) {
    if (promo != null) {
      //_navigationService.navigateTo(Routes.CreatePostViewRoute, arguments: {'promo': promo});
    } else {
      navigateToCreatePostPage();
    }
  }

  createEventWithPromo({required double? promo}) {
    if (promo != null) {
      //_navigationService.navigateTo(Routes.CreateEventViewRoute, arguments: {'promo': promo});
    } else {
      navigateToCreatePostPage();
    }
  }

  createStreamWithPromo({required double? promo}) {
    if (promo != null) {
      ///_navigationService.navigateTo(Routes.CreateLiveStreamViewRoute, arguments: {'promo': promo});
    } else {
      navigateToCreatePostPage();
    }
  }
}
