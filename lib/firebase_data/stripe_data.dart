import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeDataService {
  final CollectionReference stripeRef = FirebaseFirestore.instance.collection("stripe");
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_user");

  Future<bool> checkIfStripeSetup(String uid) async {
    bool stripeIsSetup = false;
    DocumentSnapshot docSnapshot = await stripeRef.doc(uid).get();
    if (docSnapshot.exists) {
      stripeIsSetup = true;
    }
    return stripeIsSetup;
  }

  Future<String> getStripeUID(String uid) async {
    String stripeUID;
    DocumentSnapshot docSnapshot = await stripeRef.doc(uid).get();
    if (docSnapshot.exists) {
      stripeUID = docSnapshot.data()['stripeUID'];
    }
    return stripeUID;
  }

  Future<String> updateAccountVerificationStatus(String uid) async {
    String status = "pending";
    Map<String, dynamic> accountVerificationStatus = await checkAccountVerificationStatus(uid);
    List currentlyDue = accountVerificationStatus['currently_due'];
    List pending = accountVerificationStatus['pending_verification'];
    if (currentlyDue.length > 1 || pending.isNotEmpty) {
      await stripeRef.doc(uid).update({"verified": "pending"});
    } else {
      await stripeRef.doc(uid).update({"verified": "verified"});
      status = "verified";
    }
    return status;
  }

  Future<String> submitBankingInfoToStripe(
      String uid, String stripeUID, String accountHolderName, String accountHolderType, String routingNumber, String accountNumber) async {
    String status;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'submitBankingInfoToStripe',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'stripeUID': stripeUID,
        'accountHolderName': accountHolderName,
        'accountHolderType': accountHolderType,
        'routingNumber': routingNumber,
        'accountNumber': accountNumber,
      },
    );
    if (result.data != null) {
      status = result.data;
    }
    return status;
  }

  Future<String> submitCardInfoToStripe(
      String uid, String stripeUID, String cardNumber, int expMonth, int expYear, String cvcNumber, String cardHolderName) async {
    String status;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'submitCardInfoToStripe',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'stripeUID': stripeUID,
        "cardNumber": cardNumber,
        "expMonth": expMonth,
        "expYear": expYear,
        "cvcNumber": cvcNumber,
        "cardHolderName": cardHolderName,
      },
    );
    if (result.data != null) {
      status = result.data;
    }
    return status;
  }

  Future<String> submitTicketPurchaseToStripe(
      String uid,
      double chargeAmount,
      double feeCharge,
      int numberOfTickets,
      List<Map<String, dynamic>> ticketsToPurchase,
      String eventID,
      String eventHostUID,
      String cardNumber,
      int expMonth,
      int expYear,
      String cvcNumber,
      String cardHolderName,
      String email) async {
    String status;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'submitTicketPurchaseToStripe',
    );
    int chargeInCents = int.parse((chargeAmount.toStringAsFixed(2)).replaceAll(".", ""));
    int feeChargeInCents = int.parse((feeCharge.toStringAsFixed(2)).replaceAll(".", ""));
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'chargeAmount': chargeInCents,
        "feeCharge": feeChargeInCents,
        "numberOfTickets": numberOfTickets,
        "ticketsToPurchase": ticketsToPurchase,
        "eventID": eventID,
        "eventHostUID": eventHostUID,
        "cardNumber": cardNumber,
        "expMonth": expMonth,
        "expYear": expYear,
        "cvcNumber": cvcNumber,
        "cardHolderName": cardHolderName,
        "email": email,
      },
    );
    if (result.data != null) {
      status = result.data;
    }
    return status;
  }

  Future<Map<String, dynamic>> checkAccountVerificationStatus(String uid) async {
    Map<String, dynamic> res;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'checkAccountVerificationStatus',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
    if (result.data != null) {
      res = Map<String, dynamic>.from(result.data);
    }
    return res;
  }

  Future<Map<String, dynamic>> getStripeAccountBalance(String uid, String stripeUID) async {
    Map<String, dynamic> res;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getStripeAccountBalance',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'stripeUID': stripeUID,
      },
    );
    if (result.data != null) {
      res = Map<String, dynamic>.from(result.data);
    }
    return res;
  }

  Future<String> performInstantStripePayout(String uid, String stripeUID) async {
    String status;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'performInstantStripePayout',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'stripeUID': stripeUID,
      },
    );
    if (result.data != null) {
      status = result.data;
    }
    return status;
  }
}
