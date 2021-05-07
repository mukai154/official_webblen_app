import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/add_to_calendar.dart';
import 'package:webblen/utils/url_handler.dart';

class LiveStreamDetailsViewModel extends BaseViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  UserDataService? _userDataService = locator<UserDataService>();
  LiveStreamDataService? _streamDataService = locator<LiveStreamDataService>();
  TicketDistroDataService? _ticketDistroDataService = locator<TicketDistroDataService>();
  DynamicLinkService? _dynamicLinkService = locator<DynamicLinkService>();
  ShareService? _shareService = locator<ShareService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///STREAM HOST
  WebblenUser? host;
  bool isHost = false;

  ///STREAM
  WebblenLiveStream stream = WebblenLiveStream();
  bool hasSocialAccounts = false;
  bool streamIsLive = false;

  ///TICKETS
  WebblenTicketDistro? ticketDistro;

  ///INITIALIZE
  initialize(String id) async {
    setBusy(true);

    //get stream data
    stream = await _streamDataService!.getStreamByID(id);
    if (!stream.isValid()) {
      _customNavigationService.navigateBack();
      return;
    }

    //check if stream is live
    isStreamLive();

    //get tickets if they exist
    if (stream.hasTickets!) {
      ticketDistro = await _ticketDistroDataService!.getTicketDistroByID(stream.id);
    }

    //check if stream has social accounts
    if ((stream.fbUsername != null && stream.fbUsername!.isNotEmpty) ||
        (stream.instaUsername != null && stream.instaUsername!.isNotEmpty) ||
        (stream.twitterUsername != null && stream.twitterUsername!.isNotEmpty) ||
        (stream.website != null && stream.website!.isNotEmpty)) {
      hasSocialAccounts = true;
    }

    //get author info
    host = await _userDataService!.getWebblenUserByID(stream.hostID);

    if (user.id == stream.hostID) {
      isHost = true;
    }

    notifyListeners();
    setBusy(false);
  }

  isStreamLive() {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = stream.startDateTimeInMilliseconds!;
    int? eventEndDateInMilli = stream.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli!) {
      streamIsLive = true;
    } else {
      streamIsLive = false;
    }
    notifyListeners();
  }

  addToCalendar() {
    addStreamToCalendar(webblenStream: stream);
  }

  ///TODO: DO WE WANT TO DISPLAY "TARGET AUDIENCE" OF A STREAM TO SOMEONE WATCHING THE STREAM?
  // openMaps() {
  //   _locationService.openMaps(address: stream.audienceLocation);
  // }

  openFacebook() {
    if (stream.fbUsername != null) {
      String url = "https://facebook.com/${stream.fbUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openInstagram() {
    if (stream.instaUsername != null) {
      String url = "https://instagram.com/${stream.instaUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openTwitter() {
    if (stream.twitterUsername != null) {
      String url = "https://twitter.com/${stream.twitterUsername}";
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  openWebsite() {
    if (stream.website != null) {
      String url = stream.website!;
      UrlHandler().launchInWebViewOrVC(url);
    }
  }

  ///DIALOGS & BOTTOM SHEETS
  showContentOptions() async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      variant: isHost ? BottomSheetType.contentAuthorOptions : BottomSheetType.contentOptions,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "edit") {
        //edit
        // _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute, arguments: {
        //   'id': stream.id,
        // });
      } else if (res == "share") {
        //share
        WebblenUser author = await _userDataService!.getWebblenUserByID(stream.hostID);
        String url = await _dynamicLinkService!.createLiveStreamLink(authorUsername: author.username, stream: stream);
        _shareService!.shareLink(url);
      } else if (res == "report") {
        //report
        _streamDataService!.reportStream(streamID: stream.id, reporterID: user.id);
      } else if (res == "delete") {
        //delete
        deleteContentConfirmation();
      }
    }
  }

  deleteContentConfirmation() async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      title: "Delete Stream",
      description: "Are You Sure You Want to Delete this Stream?",
      mainButtonTitle: "Delete Stream",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "confirmed") {
        await _streamDataService!.deleteStream(stream: stream);
        _customNavigationService.navigateBack();
      }
    }
  }

  ///NAVIGATION
  navigateToUserView(String id) {
    _customNavigationService.navigateToUserView(id);
  }

  navigateToStreamHost(String id) async {
    bool hasCameraPermission = await _permissionHandlerService.hasCameraPermission();
    if (hasCameraPermission) {
      bool hasMicrophonePermission = await _permissionHandlerService.hasMicrophonePermission();
      print(hasMicrophonePermission);
      if (hasMicrophonePermission) {
        _customNavigationService.navigateToLiveStreamHostView(id);
      }
    }
  }

  navigateToStreamViewer(String id) {
    _customNavigationService.navigateToLiveStreamViewerView(id);
  }

// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
