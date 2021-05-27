import 'package:stacked/stacked.dart';
import 'package:webblen/models/webblen_user.dart';

class ReactiveUserService with ReactiveServiceMixin {
  final _userLoggedIn = ReactiveValue<bool>(false);
  final _user = ReactiveValue<WebblenUser>(WebblenUser());

  bool get userLoggedIn => _userLoggedIn.value;
  WebblenUser get user => _user.value;

  void updateUserLoggedIn(bool val) => _userLoggedIn.value = val;
  void updateUser(WebblenUser val) => _user.value = val;

  reactiveUserService() {
    listenToReactiveValues([_userLoggedIn, _user]);
  }
}
