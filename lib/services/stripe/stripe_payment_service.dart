import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';

class StripePaymentService {
  CollectionReference stripeRef = FirebaseFirestore.instance.collection("stripe");
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  Future<bool> validatePaymentMethodFromCard({
    required String cardNum,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String name,
  }) async {
    String stripeKey = await _platformDataService.getStripePubKey();
    if (stripeKey.isNotEmpty) {
      StripeApi.init(stripeKey);
      StripeCard card = StripeCard(number: cardNum, cvc: cvc, expMonth: expMonth, expYear: expYear);
      Map<String, dynamic> res = await StripeApi.instance.createPaymentMethodFromCard(card);
      if (res['card']['funding'] != 'debit') {
        _customDialogService.showErrorDialog(description: "Please use a valid DEBIT card");
        return false;
      }
      print(res);
    }
    return true;
  }

  Future<String> createPaymentMethodFromCard({
    required String uid,
    required String cardNum,
    required int expMonth,
    required int expYear,
    required String cvcNum,
    required String cardHolderName,
  }) async {
    String status = "passed";
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createPaymentMethodFromCard',
    );

    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'uid': uid,
      "cardNum": cardNum,
      "expMonth": expMonth,
      "expYear": expYear,
      "cvcNum": cvcNum,
      "cardHolderName": cardHolderName,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      if (result.data != "passed") {
        status = "failed";
        _customDialogService.showErrorDialog(description: result.data['raw']['message']);
      }
    }
    return status;
  }

  Future<String> createPaymentMethodFromBankInfo({
    required String uid,
    required String accountHolderName,
    required String accountHolderType,
    required String routingNumber,
    required String accountNumber,
  }) async {
    String status = "passed";
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createPaymentMethodFromBankInfo',
    );

    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'uid': uid,
      "accountHolderName": accountHolderName,
      "accountHolderType": accountHolderType,
      "routingNumber": routingNumber,
      "accountNumber": accountNumber,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      if (result.data != "passed") {
        status = "failed";
        _customDialogService.showErrorDialog(description: result.data['raw']['message']);
      }
    }
    return status;
  }

  Future<String?> processTicketPurchase({
    required String eventTitle,
    required String purchaserID,
    required String eventHostID,
    required String eventHostName,
    required double totalCharge,
    required double ticketCharge,
    required int numberOfTickets,
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvcNumber,
    required String cardHolderName,
    required String email,
  }) async {
    String? status;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'processTicketPurchase',
    );

    int ticketChargeInCents = int.parse((ticketCharge.toStringAsFixed(2)).replaceAll(".", ""));
    int totalChargeInCents = int.parse((totalCharge.toStringAsFixed(2)).replaceAll(".", ""));

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'eventTitle': eventTitle,
        'purchaserID': purchaserID,
        'eventHostID': eventHostID,
        'eventHostName': eventHostName,
        'totalCharge': totalChargeInCents,
        'ticketCharge': ticketChargeInCents,
        'numberOfTickets': numberOfTickets,
        'cardNumber': cardNumber,
        'expMonth': expMonth,
        'expYear': expYear,
        'cvcNumber': cvcNumber,
        'cardHolderName': cardHolderName,
        'email': email,
      },
    ).catchError((e) {
      print(e);
    });
    if (result.data != null) {
      status = result.data.toString();
      print(status);
    }
    return status;
  }

  Future<String> processInstantPayout({
    required String uid,
  }) async {
    String status = "passed";
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'processInstantPayout',
    );

    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'uid': uid,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      if (result.data != "passed") {
        status = "failed";
        _customDialogService.showErrorDialog(description: result.data['raw']['message']);
      }
    }
    return status;
  }
}
