import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
import 'package:webblen/utils/add_to_calendar.dart';
import 'package:webblen/utils/url_handler.dart';

class LiveStreamDetailsViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  UserDataService? _userDataService = locator<UserDataService>();
  LiveStreamDataService? _streamDataService = locator<LiveStreamDataService>();
  TicketDistroDataService? _ticketDistroDataService = locator<TicketDistroDataService>();
  LocationService? _locationService = locator<LocationService>();
  CommentDataService? _commentDataService = locator<CommentDataService>();
  NotificationDataService? _notificationDataService = locator<NotificationDataService>();
  WebblenBaseViewModel? _webblenBaseViewModel = locator<WebblenBaseViewModel>();
  DynamicLinkService? _dynamicLinkService = locator<DynamicLinkService>();
  ShareService? _shareService = locator<ShareService>();

  ///STREAM HOST
  WebblenUser? host;
  bool isHost = false;

  ///STREAM
  late WebblenLiveStream stream;
  bool hasSocialAccounts = false;
  bool streamIsLive = false;

  ///TICKETS
  WebblenTicketDistro? ticketDistro;

  ///INITIALIZE
  initialize(BuildContext context) async {
    setBusy(true);

    Map<String, dynamic> args = {};

    String streamID = args['id'] ?? "";

    //get stream data
    var res = await _streamDataService!.getStreamByID(streamID);
    if (res == null) {
      _navigationService!.back();
      return;
    } else {
      stream = res;
    }

    //check if stream is live
    isStreamLive();

    //get tickets if they exist
    if (stream.hasTickets!) {
      ticketDistro = await (_ticketDistroDataService!.getTicketDistroByID(stream.id) as FutureOr<WebblenTicketDistro?>);
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

    if (_webblenBaseViewModel!.uid == stream.hostID) {
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

  ///STREAMING
  streamNow() async {
    bool permissionsGranted = await verifyPermissions();
    if (permissionsGranted) {
      navigateToStreamHost(stream.id);
    }
  }

  Future<bool> verifyPermissions() async {
    //check camera permissions
    PermissionStatus cameraPermission = await Permission.camera.status;
    if (cameraPermission == null) {
      cameraPermission = await Permission.camera.request();
    }
    if (cameraPermission == PermissionStatus.denied || cameraPermission == PermissionStatus.permanentlyDenied) {
      DialogResponse? response = await _dialogService!.showDialog(
        title: "Camera Usage Required",
        description: "Enable access to your camera in order to stream video on Webblen in the app settings.",
        cancelTitle: "Cancel",
        cancelTitleColor: appTextButtonColor(),
        buttonTitle: "Open App Settings",
        buttonTitleColor: appTextButtonColor(),
        barrierDismissible: true,
      );
      if (response != null && response.confirmed) {
        openAppSettings();
      }
      return false;
    }

    //check microphone permissions
    PermissionStatus micorphonePermission = await Permission.microphone.status;
    if (micorphonePermission == null) {
      micorphonePermission = await Permission.microphone.request();
    }
    if (micorphonePermission == PermissionStatus.denied || micorphonePermission == PermissionStatus.permanentlyDenied) {
      DialogResponse? response = await _dialogService!.showDialog(
        title: "Microphone Usage Required",
        description: "Enable access to your microphone in order to stream video on Webblen in the app settings.",
        cancelTitle: "Cancel",
        cancelTitleColor: appTextButtonColor(),
        buttonTitle: "Open App Settings",
        buttonTitleColor: appTextButtonColor(),
        barrierDismissible: true,
      );
      if (response != null && response.confirmed) {
        openAppSettings();
      }
      return false;
    }

    return true;
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
        WebblenUser author = await (_userDataService!.getWebblenUserByID(stream.hostID) as FutureOr<WebblenUser>);
        String url = await _dynamicLinkService!.createLiveStreamLink(authorUsername: author.username, stream: stream);
        _shareService!.shareLink(url);
      } else if (res == "report") {
        //report
        _streamDataService!.reportStream(streamID: stream.id, reporterID: _webblenBaseViewModel!.uid);
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
        _navigationService!.back();
      }
    }
  }

  ///NAVIGATION
  navigateToUserView(String? id) {
   // _navigationService.navigateTo(Routes.UserProfileView, arguments: {'id': id});
  }

  navigateToStreamHost(String? id) {
    //_navigationService.navigateTo(Routes.LiveStreamHostViewRoute, arguments: {'id': id});
  }

// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
