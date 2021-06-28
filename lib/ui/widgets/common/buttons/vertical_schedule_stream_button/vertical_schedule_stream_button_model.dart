import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class VerticalScheduleStreamButtonModel extends BaseViewModel {
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  onTap() {
    customNavigationService.navigateToCreateLiveStreamView("new");
  }
}
