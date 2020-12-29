import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/firestore/user_data_service.dart';

class PostTextBlockViewModel extends BaseViewModel {
  UserDataService _userDataService = locator<UserDataService>();

  String authorImageURL = "https://icon2.cleanpng.com/20180228/hdq/kisspng-circle-angle-material-gray-circle-pattern-5a9716f391f119.9417320315198512515978.jpg";
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
      notifyListeners();
      setBusy(false);
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
