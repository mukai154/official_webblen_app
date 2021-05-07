import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

class SetUpDirectDepositViewModel extends BaseViewModel {
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  NavigationService _navigationService = locator<NavigationService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///BANK DATA
  List<String> accountTypes = ["individual", "company"];

  String accountHolderName = "";
  String accountHolderType = "individual";
  String routingNum = "";
  String accountNum = "";

  initialize() {}

  updateAccountHolderName(String val) {
    accountHolderName = val.trim();
    notifyListeners();
  }

  updateAccountHolderType(String val) {
    accountHolderType = val;
    notifyListeners();
  }

  updateRoutingNum(String val) {
    routingNum = val.trim();
    notifyListeners();
  }

  updateAccountNum(String val) {
    accountNum = val.trim();
    notifyListeners();
  }

  bool formIsValid() {
    bool isValid = true;
    if (accountHolderName.isEmpty) {
      _customDialogService.showErrorDialog(description: "Please Enter a Name for the Account");
      isValid = false;
    } else if (routingNum.length != 9) {
      _customDialogService.showErrorDialog(description: "Please Enter a Valid US Routing Number");
      isValid = false;
    } else if (accountNum.isEmpty) {
      _customDialogService.showErrorDialog(description: "Please Enter a Valid Account Number");
      isValid = false;
    }
    return isValid;
  }

  submit() async {
    setBusy(true);
    if (formIsValid()) {
      if (user.isValid()) {
        String status = await _stripePaymentService.createPaymentMethodFromBankInfo(
          uid: user.id!,
          accountHolderName: accountHolderName,
          accountHolderType: accountHolderType,
          routingNumber: routingNum,
          accountNumber: accountNum,
        );
        if (status == "passed") {
          setBusy(false);
          _navigationService.back();
          _customDialogService.showSuccessDialog(title: "Bank Added", description: "Earnings will deposited to this account");
        }
      }
    }
    setBusy(false);
  }
}
