import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/user_algorand_account_data.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class OnboardingCompleteViewModel extends BaseViewModel {
  UserDataService _userDataService = locator<UserDataService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService =
      locator<CustomNavigationService>();
  UserAlgorandAccountDataService _userAlgorandAccountDataService = locator<UserAlgorandAccountDataService>();

  ///USER
  WebblenUser get user => _reactiveUserService.user;

  late double reward;
  bool pressedButton = false;

  testEarningWebblen() async {
    pressedButton = true;
    
    reward = await _platformDataService.getNewAccountReward();
    await _userDataService.depositWebblen(uid: user.id!, amount: reward);
    await _userDataService.completeOnboarding(uid: user.id!);

    notifyListeners();
  }
}
