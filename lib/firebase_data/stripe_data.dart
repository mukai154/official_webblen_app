import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeDataService {
  final CollectionReference stripeRef = Firestore.instance.collection("stripe");
  final CollectionReference userRef = Firestore.instance.collection("webblen_user");

  Future<bool> checkIfStripeSetup(String uid) async {
    bool stripeIsSetup = false;
    DocumentSnapshot documentSnapshot = await stripeRef.document(uid).get();
    if (documentSnapshot.exists) {
      stripeIsSetup = true;
    }
    return stripeIsSetup;
  }

  Future<String> getStripeUID(String uid) async {
    String stripeUID;
    DocumentSnapshot documentSnapshot = await stripeRef.document(uid).get();
    if (documentSnapshot.exists) {
      stripeUID = documentSnapshot.data['stripeUID'];
    }
    return stripeUID;
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

  Future<String> submitCardInfoToStripe(String uid, String stripeUID, String cardNumber, int expMonth, int expYear, int cvcNumber) async {
    String status;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'submitCardInfoToStripe',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'stripeUID': stripeUID,
        'cardNumber': cardNumber,
        'expMonth': expMonth,
        'expYear': expYear,
        'cvcNumber': cvcNumber,
      },
    );
    if (result.data != null) {
      status = result.data;
    }
    return status;
  }
}
