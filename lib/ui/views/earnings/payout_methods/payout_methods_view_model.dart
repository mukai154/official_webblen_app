import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';

class PayoutMethodsViewModel extends StreamViewModel<UserStripeInfo> with ReactiveServiceMixin {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  ///CURRENT USER
  UserStripeInfo? _userStripeInfo;
  UserStripeInfo? get userStripeInfo => _userStripeInfo;
  WebblenUser get user => _reactiveUserService.user;

  bool stripeAccountIsSetup = false;
  bool dismissedSetupAccountNotice = false;

  bool retrievingAccountStatus = true;
  bool retrievedAccountStatus = false;

  initialize() {
    setBusy(true);
  }

  ///STREAM DATA
  @override
  void onData(UserStripeInfo? data) {
    if (data != null) {
      if (data.isValid()) {
        _userStripeInfo = data;
        notifyListeners();
        setBusy(false);
      }
    }
  }

  @override
  Stream<UserStripeInfo> get stream => streamUserStripeInfo();

  Stream<UserStripeInfo> streamUserStripeInfo() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      UserStripeInfo stripeInfo = UserStripeInfo();
      stripeInfo = await _stripeConnectAccountService.getStripeConnectAccountByUID(user.id);
      if (stripeInfo.isValid() && !retrievedAccountStatus && !retrievingAccountStatus) {
        retrieveAndUpdateStripeAccountStatus();
      }
      yield stripeInfo;
    }
  }

  retrieveAndUpdateStripeAccountStatus() async {
    retrievingAccountStatus = true;
    notifyListeners();
    Map<String, dynamic> accountStatus = await _stripeConnectAccountService.retrieveWebblenStripeAccountStatus(uid: user.id!);

    if (accountStatus.isNotEmpty) {
      await _stripeConnectAccountService.updateStripeAccountStatus(uid: user.id!, accountStatus: accountStatus);
    }

    retrievingAccountStatus = false;
    retrievedAccountStatus = true;
    notifyListeners();
  }
}
