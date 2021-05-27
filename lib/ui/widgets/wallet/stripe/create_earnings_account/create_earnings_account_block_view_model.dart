import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';

class CreateEarningsAccountBlockViewModel extends ReactiveViewModel {
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///CURRENT USER
  WebblenUser get user => _reactiveUserService.user;

  createStripeConnectAccount() async {
    _stripeConnectAccountService.createStripeConnectAccount(uid: user.id!);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];
}
