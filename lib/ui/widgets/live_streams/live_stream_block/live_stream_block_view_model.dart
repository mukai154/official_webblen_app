import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

class LiveStreamBlockViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  NavigationService? _navigationService = locator<NavigationService>();
  LiveStreamDataService? _liveStreamDataService = locator<LiveStreamDataService>();
  UserDataService? _userDataService = locator<UserDataService>();
  WebblenBaseViewModel? _webblenBaseViewModel = locator<WebblenBaseViewModel>();

  bool isLive = false;
  bool savedStream = false;
  String? hostImageURL = "https://icon2.cleanpng.com/20180228/hdq/kisspng-circle-angle-material-gray-circle-pattern-5a9716f391f119.9417320315198512515978.jpg";
  String? hostUsername = "";

  initialize(WebblenLiveStream stream) {
    setBusy(true);

    //check if user saved event
    if (stream.savedBy!.contains(_webblenBaseViewModel!.uid)) {
      savedStream = true;
    }

    //check if event is happening now
    isStreamLive(stream);

    _userDataService!.getWebblenUserByID(stream.hostID).then((res) {
      if (res is String) {
        //print(String);
      } else {
        hostImageURL = res!.profilePicURL;
        hostUsername = res.username;
      }
      notifyListeners();
      setBusy(false);
    });
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
    await _liveStreamDataService!.saveUnsaveStream(uid: _webblenBaseViewModel!.uid, streamID: streamID, savedStream: savedStream);
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToStreamView({String? streamID}) async {
    // String res = await _navigationService.navigateTo(Routes.LiveStreamViewRoute, arguments: {'id': streamID});
    // if (res == "stream no longer exists") {
    //   _snackbarService.showSnackbar(
    //     title: 'Uh Oh...',
    //     message: "This stream no longer exists",
    //     duration: Duration(seconds: 5),
    //   );
    // }
  }

  navigateToUserView(String? id) {
    //_navigationService.navigateTo(Routes.UserProfileView, arguments: {'id': id});
  }
}
