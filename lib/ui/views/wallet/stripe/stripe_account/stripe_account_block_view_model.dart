import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

class StripeAccountBlockViewModel extends StreamViewModel<UserStripeInfo> with ReactiveServiceMixin {
  NavigationService _navigationService = locator<NavigationService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  // StripePaymentService? _stripePaymentService = locator<StripePaymentService>();
  // WebblenBaseViewModel? webblenBaseViewModel = locator<WebblenBaseViewModel>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  ///CURRENT USER
  UserStripeInfo? _userStripeInfo;
  UserStripeInfo? get userStripeInfo => _userStripeInfo;
  WebblenUser get user => _reactiveUserService.user;

  bool stripeAccountIsSetup = false;
  bool dismissedSetupAccountNotice = false;

  bool initializedAccountUpdate = false;
  bool retrievingAccountStatus = true;
  bool retrievedAccountStatus = false;

  bool performingInstantPayout = false;

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
      if (stripeInfo.isValid() && !initializedAccountUpdate) {
        initializedAccountUpdate = true;
        notifyListeners();
        retrieveAndUpdateStripeAccountStatus();
      }
      yield stripeInfo;
    }
  }

  completeCreatingStripeEarningsAccount() async {
    _stripeConnectAccountService.createStripeConnectAccount(uid: user.id!);
  }

  retrieveAndUpdateStripeAccountStatus() async {
    retrievingAccountStatus = true;
    notifyListeners();
    Map<String, dynamic> accountStatus = await _stripeConnectAccountService.retrieveWebblenStripeAccountStatus(uid: user.id!);

    if (accountStatus.isNotEmpty) {
      await _stripeConnectAccountService.updateStripeAccountStatus(uid: user.id!, accountStatus: accountStatus);
    }

    await _stripeConnectAccountService.updateStripeAccountBalance(uid: user.id!);

    retrievingAccountStatus = false;
    retrievedAccountStatus = true;
    notifyListeners();
  }

  showPendingAlert() {
    _customDialogService.showEarningsAccountPendingAlert();
  }

  showStripeAccountMenu() async {
    bool performInstantPayout = await _customBottomSheetService.showStripeBottomSheet();
    if (performInstantPayout) {
      if (userStripeInfo!.availableBalance == null || userStripeInfo!.availableBalance! < 5) {
        _customDialogService.showErrorDialog(description: "Balance must be at least \$5.00 to perform an instant payout");
      } else {
        performingInstantPayout = true;
        notifyListeners();
        String status = await _stripePaymentService.processInstantPayout(uid: user.id!);
        if (status == "passed") {
          retrievingAccountStatus = true;
          performingInstantPayout = false;
          notifyListeners();
          await retrieveAndUpdateStripeAccountStatus();
          _customDialogService.showSuccessDialog(title: "Instant Payout Success", description: "Please allow up to an hour for you funds to be deposited");
        }
      }
    }
  }

  ///NAVIGATION
  navigateToCreatePostPage() {
    // _navigationService.navigateTo(Routes.CreatePostViewRoute);
  }

  navigateToRedeemedRewardsView() {
    //_navigationService.navigateTo(Routes.RedeemedRewardsViewRoute, arguments: {'currentUser': webblenBaseViewModel.user});
  }

  navigateToCreateEventPage() {
    // _navigationService.navigateTo(Routes.CreateEventViewRoute);
  }
}
