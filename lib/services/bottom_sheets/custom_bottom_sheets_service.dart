import 'dart:async';

import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

class CustomBottomSheetService {
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  NavigationService _navigationService = locator<NavigationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  AuthService _authService = locator<AuthService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();
  UserDataService _userDataService = locator<UserDataService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();
  PostDataService _postDataService = locator<PostDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();

  //filters
  openFilter() async {
    _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.homeFilter,
      takesInput: true,
      customData: {
        'currentCityName': _reactiveContentFilterService.cityName,
        'currentAreaCode': _reactiveContentFilterService.areaCode,
        'currentSortBy': _reactiveContentFilterService.sortByFilter,
        'currentTagFilter': _reactiveContentFilterService.tagFilter,
      },
    );
  }

  showCurrentUserOptions(WebblenUser user) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.currentUserOptions,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "saved") {
        //saved
        _navigationService.navigateTo(Routes.SavedContentViewRoute);
      } else if (res == "edit profile") {
        //edit profile
        _navigationService.navigateTo(Routes.EditProfileViewRoute);
      } else if (res == "share profile") {
        //share profile
        String? url = await _dynamicLinkService.createProfileLink(user: user);
        _shareService.shareLink(url);
      } else if (res == "settings") {
        _navigationService.navigateTo(Routes.SettingsViewRoute);
      }
    }
  }

  //bottom sheet for new post, event, or stream
  showAddContentOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.addContent,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "new post") {
        _navigationService.navigateTo(Routes.CreatePostViewRoute(id: "new", promo: 0));
      } else if (res == "new stream") {
        _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute(id: "new", promo: 0));
      } else if (res == "new event") {
        _navigationService.navigateTo(Routes.CreateEventViewRoute(id: "new", promo: 0));
      }
    }
  }

  //bottom sheet for options one can take with post, event, or stream
  Future showContentOptions({required dynamic content}) async {
    WebblenUser user = _reactiveUserService.user;
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      customData: content is WebblenEvent && user.id == content.authorID && content.hasTickets! ? {'checkInAttendees': true} : {'checkInAttendees': false},
      variant: content is WebblenLiveStream
          ? user.id == content.hostID
              ? BottomSheetType.contentAuthorOptions
              : BottomSheetType.contentOptions
          : user.id == content.authorID
              ? BottomSheetType.contentAuthorOptions
              : BottomSheetType.contentOptions,
    );

    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "edit") {
        if (content is WebblenPost) {
          //edit post
          _navigationService.navigateTo(Routes.CreatePostViewRoute(id: content.id, promo: 0));
        } else if (content is WebblenEvent) {
          //edit event
          _navigationService.navigateTo(Routes.CreateEventViewRoute(id: content.id, promo: 0));
        } else if (content is WebblenLiveStream) {
          //edit stream
          _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute(id: content.id, promo: 0));
        }
      } else if (res == "share") {
        if (content is WebblenPost) {
          //share post link
          WebblenUser author = await _userDataService.getWebblenUserByID(content.authorID);
          if (author.isValid()) {
            String? url = await _dynamicLinkService.createPostLink(authorUsername: author.username, post: content);
            _shareService.shareLink(url);
          }
        } else if (content is WebblenEvent) {
          //share event link
          WebblenUser author = await _userDataService.getWebblenUserByID(content.authorID);
          if (author.isValid()) {
            String? url = await _dynamicLinkService.createEventLink(authorUsername: author.username, event: content);
            _shareService.shareLink(url);
          }
        } else if (content is WebblenLiveStream) {
          //share stream link
          WebblenUser author = await _userDataService.getWebblenUserByID(content.hostID);
          if (author.isValid()) {
            String? url = await _dynamicLinkService.createLiveStreamLink(authorUsername: author.username, stream: content);
            _shareService.shareLink(url);
          }
        }
      } else if (res == "report") {
        if (content is WebblenPost) {
          //report post
          _postDataService.reportPost(postID: content.id, reporterID: user.id);
        } else if (content is WebblenEvent) {
          //report event
          _eventDataService.reportEvent(eventID: content.id, reporterID: user.id);
        } else if (content is WebblenLiveStream) {
          //report stream
          _liveStreamDataService.reportStream(streamID: content.id, reporterID: user.id);
        }
      } else if (res == "check in") {
        //scanner content
        _navigationService.navigateTo(Routes.CheckInAttendeesViewRoute(id: content.id));
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
      var sheetResponse = await _bottomSheetService.showCustomSheet(
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
          _postDataService.deletePost(post: content);
          _customDialogService.showPostDeletedDialog();
          return true;
        }
      }
    } else if (content is WebblenEvent) {
      var sheetResponse = await _bottomSheetService.showCustomSheet(
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
          _eventDataService.deleteEvent(event: content);
          _customDialogService.showEventDeletedDialog();
          return true;
        }
      }
    } else if (content is WebblenLiveStream) {
      var sheetResponse = await _bottomSheetService.showCustomSheet(
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
          _liveStreamDataService.deleteStream(stream: content);
          _customDialogService.showStreamDeletedDialog();
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> showCancelCreatingContentBottomSheet({dynamic content}) async {
    if (content is WebblenPost) {
      var sheetResponse = await _bottomSheetService.showCustomSheet(
        title: "Discard Post?",
        description: "If you go back now, your post will be discarded",
        mainButtonTitle: "Discard Post",
        secondaryButtonTitle: "Cancel",
        barrierDismissible: true,
        variant: BottomSheetType.destructiveConfirmation,
      );
      if (sheetResponse != null) {
        String? res = sheetResponse.responseData;
        if (res == "confirmed") {
          return true;
        }
      }
    } else if (content is WebblenEvent) {
      var sheetResponse = await _bottomSheetService.showCustomSheet(
        title: "Discard Event?",
        description: "If you go back now, your event will be discarded",
        mainButtonTitle: "Discard Event",
        secondaryButtonTitle: "Cancel",
        barrierDismissible: true,
        variant: BottomSheetType.destructiveConfirmation,
      );
      if (sheetResponse != null) {
        String? res = sheetResponse.responseData;
        if (res == "confirmed") {
          _eventDataService.deleteEvent(event: content);
          _customDialogService.showEventDeletedDialog();
          return true;
        }
      }
    } else if (content is WebblenLiveStream) {
      var sheetResponse = await _bottomSheetService.showCustomSheet(
        title: "Discard Stream?",
        description: "If you go back now, your stream will be discarded",
        mainButtonTitle: "Discard Stream",
        secondaryButtonTitle: "Cancel",
        barrierDismissible: true,
        variant: BottomSheetType.destructiveConfirmation,
      );
      if (sheetResponse != null) {
        String? res = sheetResponse.responseData;
        if (res == "confirmed") {
          _liveStreamDataService.deleteStream(stream: content);
          _customDialogService.showStreamDeletedDialog();
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> showCancelEditingContentBottomSheet() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Discard Edits?",
      description: "If you go back now, your changes will not be saved",
      mainButtonTitle: "Discard Edits",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "confirmed") {
        return true;
      }
    }
    return false;
  }

  Future<bool> showCheckoutEventDialog() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Check Out of Event?",
      description: "Checking out of an event means you cannot earn WBLN from it",
      mainButtonTitle: "Check Out",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "confirmed") {
        return true;
      }
    }
    return false;
  }

  Future<bool> showStripeBottomSheet() async {
    bool performInstantPayout = false;
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.stripeAccount,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "instant payout") {
        performInstantPayout = true;
      } else if (res == "balance history") {
        //navigate to payout methods
        _navigationService.navigateTo(Routes.USDBalanceHistoryViewRoute);
      } else if (res == "payout methods") {
        //navigate to payout methods
        _navigationService.navigateTo(Routes.PayoutMethodsViewRoute);
      } else if (res == "how do earnings work") {
        //navigate to how earnings work
        _navigationService.navigateTo(Routes.HowEarningsWorkViewRoute);
      }
    }
    return performInstantPayout;
  }

  Future<String?> showImageSelectorBottomSheet() async {
    String? source;
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.imagePicker,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;

      //get image from camera or gallery
      source = res;
    }
    return source;
  }

  showGiftWebblenBottomSheet({required String contentID, required String hostID}) async {
    await _bottomSheetService.showCustomSheet(
      customData: {'contentID': contentID, 'hostID': hostID},
      barrierDismissible: true,
      variant: BottomSheetType.giftOrPurchaseWBLN,
    );
  }

  showLogoutBottomSheet() async {
    ThemeService _themeService = locator<ThemeService>();
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Log Out",
      description: "Are You Sure You Want to Log Out?",
      mainButtonTitle: "Log Out",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "confirmed") {
        await _authService.signOut();
        _reactiveUserService.updateUserLoggedIn(false);
        _reactiveUserService.updateUser(WebblenUser());
        if (_themeService.selectedThemeMode != ThemeManagerMode.light) {
          _themeService.setThemeMode(ThemeManagerMode.light);
        }
        _navigationService.pushNamedAndRemoveUntil(Routes.RootViewRoute);
      }
    }
  }
}
