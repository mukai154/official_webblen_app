import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

class SetupInstantDepositViewModel extends BaseViewModel {
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  NavigationService _navigationService = locator<NavigationService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///CARD DATA
  bool cvcFocused = false;
  String cardNumber = "";
  String expiryDate = "MM/YY";
  int? expMonth;
  int? expYear;
  String cardHolderName = "";
  String cvcNumber = "";

  updateCardHolderName(String val) {
    cvcFocused = false;
    cardHolderName = val.trim();
    notifyListeners();
  }

  updateCardNumber(String val) {
    cvcFocused = false;
    cardNumber = val.replaceAll(" ", "");
    notifyListeners();
  }

  updateExpiryDate(String val) {
    cvcFocused = false;
    expiryDate = val.trim();
    notifyListeners();
  }

  updateExpiryMonth(String val) {
    cvcFocused = false;
    expMonth = int.parse(val);
    notifyListeners();
  }

  updateExpiryYear(String val) {
    cvcFocused = false;

    expYear = int.parse("20$val"); //sets year to 20XX
    notifyListeners();
  }

  updateCVC(String val) {
    cvcFocused = true;
    cvcNumber = val;
    notifyListeners();
  }

  bool formIsValid() {
    bool isValid = true;
    if (cardNumber.length != 16) {
      _customDialogService.showErrorDialog(description: "Invalid Card Number");
      isValid = false;
    } else if (expMonth == null || expMonth! < 1 || expMonth! > 12) {
      _customDialogService.showErrorDialog(description: "Invalid Expiry Month");
      isValid = false;
    } else if (expYear == null || expYear! < DateTime.now().year) {
      _customDialogService.showErrorDialog(description: "Invalid Expiry Year");
      isValid = false;
    } else if (DateTime.now().isAtSameMomentAs(DateTime(expYear!, expMonth!)) || DateTime.now().isAfter(DateTime(expYear!, expMonth!))) {
      _customDialogService.showErrorDialog(description: "This Card Has Expired");
      isValid = false;
    } else if (cvcNumber.length != 3) {
      _customDialogService.showErrorDialog(description: "Invalid CVC Code");
      isValid = false;
    } else if (cardHolderName.isEmpty) {
      _customDialogService.showErrorDialog(description: "Name Cannot Be Empty");
      isValid = false;
    }
    return isValid;
  }

  submit() async {
    setBusy(true);
    if (formIsValid()) {
      bool paymentMethodIsValid = await _stripePaymentService.validatePaymentMethodFromCard(
        cardNum: cardNumber,
        expMonth: expMonth!,
        expYear: expYear!,
        cvc: cvcNumber,
        name: cardHolderName,
      );

      if (paymentMethodIsValid) {
        if (user.isValid()) {
          String status = await _stripePaymentService.createPaymentMethodFromCard(
            uid: user.id!,
            cardNum: cardNumber,
            expMonth: expMonth!,
            expYear: expYear!,
            cvcNum: cvcNumber,
            cardHolderName: cardHolderName,
          );
          if (status == "passed") {
            setBusy(false);
            _navigationService.back();
            _customDialogService.showSuccessDialog(title: "Card Added", description: "You are now eligible for instant deposits");
          }
        }
      }
    }
    setBusy(false);
  }
}
