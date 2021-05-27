import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';
import 'package:webblen/ui/views/base/app_base_view_model.dart';

class WalletViewModel extends StreamViewModel<UserStripeInfo> with ReactiveServiceMixin {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  StripePaymentService? _stripePaymentService = locator<StripePaymentService>();
  AppBaseViewModel appBaseViewModel = locator<AppBaseViewModel>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///CURRENT USER
  UserStripeInfo? _userStripeInfo;
  UserStripeInfo? get userStripeInfo => _userStripeInfo;
  WebblenUser get user => _reactiveUserService.user;

  bool stripeAccountIsSetup = false;
  bool dismissedSetupAccountNotice = false;

  String stripeConnectURL = "";
  bool updatingStripeAccountStatus = false;

  initialize() async {
    setBusy(true);

    //get user stripe account
    stripeAccountIsSetup = await _stripeConnectAccountService.isStripeConnectAccountSetup(user.id);

    setBusy(false);
    notifyListeners();
  }

  ///STREAM DATA
  @override
  void onData(UserStripeInfo? data) {
    if (data != null) {
      if (data.stripeUID != null) {
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
      yield stripeInfo;
    }
  }

  dismissCreateStripeAccountNotice() {
    dismissedSetupAccountNotice = true;
    notifyListeners();
  }

  updateStripeAccountStatus() async {
    updatingStripeAccountStatus = true;
    notifyListeners();
  }
}
