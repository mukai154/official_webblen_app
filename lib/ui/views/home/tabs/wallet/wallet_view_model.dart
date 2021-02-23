import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

@singleton
class WalletViewModel extends StreamViewModel<UserStripeInfo> {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();

  ///CURRENT USER
  UserStripeInfo userStripeInfo;

  bool stripeAccountIsSetup = false;

  initialize(WebblenUser user) async {
    setBusy(true);

    String stripeUID = await _stripePaymentService.getStripeUID(user.id);

    if (stripeUID != null) {
      stripeAccountIsSetup = true;
    }

    setBusy(false);
  }

  ///STREAM DATA
  @override
  void onData(UserStripeInfo data) {
    if (data != null) {
      userStripeInfo = data;
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  Stream<UserStripeInfo> get stream => streamUserStripeInfo();

  Stream<UserStripeInfo> streamUserStripeInfo() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      String uid = await _authService.getCurrentUserID();
      var res = await _userDataService.getUserStripeInfoByID(uid);
      if (res is String) {
        yield null;
      } else {
        yield res;
      }
    }
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }

navigateToRedeemedRewardsView(WebblenUser user) {
    _navigationService.navigateTo(Routes.RedeemedRewardsViewRoute, arguments: {'currentUser': user});
  }
}
