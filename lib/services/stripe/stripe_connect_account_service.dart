import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/utils/url_handler.dart';

class StripeConnectAccountService {
  CollectionReference stripeRef = FirebaseFirestore.instance.collection('stripe');
  CollectionReference stripeActivityRef = FirebaseFirestore.instance.collection('stripe_connect_activity');
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  Future<bool> isStripeConnectAccountSetup(String? uid) async {
    bool isSetup = false;
    DocumentSnapshot documentSnapshot = await stripeRef.doc(uid).get();
    if (documentSnapshot.exists) {
      isSetup = true;
    }
    return isSetup;
  }

  Future<String?> getStripeUID(String? uid) async {
    String? stripeUID;
    DocumentSnapshot snapshot = await stripeRef.doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      stripeUID = data['stripeUID'];
    }
    return stripeUID;
  }

  Future<UserStripeInfo> getStripeConnectAccountByUID(String? uid) async {
    UserStripeInfo userStripeInfo = UserStripeInfo();
    String? error;
    DocumentSnapshot snapshot = await stripeRef.doc(uid).get().catchError((e) {
      error = e.message;
      print(error);
    });

    if (snapshot.exists) {
      userStripeInfo = UserStripeInfo.fromMap(snapshot.data()!);
    }
    return userStripeInfo;
  }

  createStripeConnectAccount({required String uid}) async {
    String? locale = await Devicelocale.currentLocale;
    if (locale == null) {
      print('create stripe connect account error');
    } else {
      String? country;
      if (locale.contains("-")) {
        country = locale.split('-')[1].toUpperCase();
      } else if (locale.contains('_')) {
        country = locale.split('_')[1].toUpperCase();
      }
      if (country != null) {
        String stripeConnectURL = 'https://us-central1-webblen-events.cloudfunctions.net/createWebblenStripeConnectAccount?uid=$uid&country=$country';
        UrlHandler().launchInWebViewOrVC(stripeConnectURL);
      }
    }
  }

  Future<Map<String, dynamic>> retrieveWebblenStripeAccountStatus({required String uid}) async {
    Map<String, dynamic> res = {};
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'retrieveWebblenStripeAccountStatus',
    );

    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'uid': uid,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      if (result.data is String) {
        _customDialogService.showErrorDialog(description: result.data);
      } else {
        res = Map<String, dynamic>.from(result.data);
      }
    }
    return res;
  }

  Future<void> updateStripeAccountBalance({required String uid}) async {
    print('updating account balance');
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'updateStripeAccountBalance',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
  }

  Future<void> updateStripeAccountStatus({required String uid, required Map<String, dynamic> accountStatus}) async {
    //Check if additional KYC data is required
    List currentlyDue = accountStatus['currently_due'];
    //Check if any stripe connect account data is pending verification
    List pending = accountStatus['pending_verification'];

    if (currentlyDue.length > 1) {
      await stripeRef.doc(uid).update({"verified": "pending", "actionRequired": true});
    } else if (pending.isNotEmpty) {
      await stripeRef.doc(uid).update({"verified": "pending", "actionRequired": false});
    } else {
      await stripeRef.doc(uid).update({"verified": "verified", "actionRequired": false});
    }
  }

  Future<String?> performInstantStripePayout({
    required String uid,
    required String stripeUID,
  }) async {
    String? status;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'performInstantStripePayout',
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

  Future<String?> submitBankingInfoToStripe({
    required String uid,
    required String stripeUID,
    required String accountHolderName,
    required String accountHolderType,
    required String routingNumber,
    required String accountNumber,
  }) async {
    String? status;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'submitBankingInfoWeb',
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
      status = result.data['status'];
    }
    return status;
  }

  Future<String?> submitCardInfoToStripe({
    required String uid,
    required String stripeUID,
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvcNumber,
    required String cardHolderName,
  }) async {
    String? status;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'submitCardInfoWeb',
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
      status = result.data['status'];
    }
    return status;
  }

  Future<List<DocumentSnapshot>> loadStripeTransactions({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = stripeActivityRef.where('uid', isEqualTo: id).orderBy('timePosted', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalTransactions({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = stripeActivityRef.where('uid', isEqualTo: id).orderBy('timePosted', descending: true).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }
}
