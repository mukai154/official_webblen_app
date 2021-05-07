import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class LiveStreamBlockViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  NavigationService? _navigationService = locator<NavigationService>();
  LiveStreamDataService? _liveStreamDataService = locator<LiveStreamDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  bool isLive = false;
  bool savedStream = false;
  String? hostImageURL = "";
  String? hostUsername = "";

  initialize(WebblenLiveStream stream) async {
    setBusy(true);

    //check if user saved event
    if (stream.savedBy!.contains(_reactiveUserService.user.id)) {
      savedStream = true;
    }

    //check if event is happening now
    isStreamLive(stream);

    WebblenUser author = await _userDataService.getWebblenUserByID(stream.hostID);
    if (author.isValid()) {
      hostImageURL = author.profilePicURL;
      hostUsername = author.username;
    }
    notifyListeners();
    setBusy(false);
  }

  isStreamLive(WebblenLiveStream stream) {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = stream.startDateTimeInMilliseconds!;
    int? eventEndDateInMilli = stream.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli!) {
      isLive = true;
    } else {
      isLive = false;
    }
    notifyListeners();
  }

  saveUnsaveStream({String? streamID}) async {
    if (savedStream) {
      savedStream = false;
    } else {
      savedStream = true;
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _liveStreamDataService!.saveUnsaveStream(uid: _reactiveUserService.user.id, streamID: streamID, savedStream: savedStream);
  }
}
