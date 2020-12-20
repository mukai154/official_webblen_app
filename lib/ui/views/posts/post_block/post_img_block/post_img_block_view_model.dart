import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/firestore/user_data_service.dart';

class PostImgBlockViewModel extends BaseViewModel {
  UserDataService _userDataService = locator<UserDataService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();

  String authorImageURL = "";
  String authorUsername = "";

  initialize(String uid) {
    setBusy(true);
    _userDataService.getWebblenUserByID(uid).then((res) {
      if (res is String) {
        print(String);
      } else {
        authorImageURL = res.profile_pic;
        authorUsername = res.username;
      }
      setBusy(false);
      notifyListeners();
    });
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
