import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/models/user_stripe_info.dart';

class StripeConnectAccountService {
  CollectionReference stripeRef = FirebaseFirestore.instance.collection('stripe');

  Future<bool> isStripeConnectAccountSetup(String uid) async {
    bool isSetup = false;
    DocumentSnapshot documentSnapshot = await stripeRef.doc(uid).get();
    if (documentSnapshot.exists) {
      isSetup = true;
    }
    return isSetup;
  }

  Future<String> getStripeUID(String uid) async {
    String stripeUID;
    DocumentSnapshot snapshot = await stripeRef.doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data();
      stripeUID = data['stripeUID'];
    }
    return stripeUID;
  }

  Future getStripeConnectAccountByUID(String uid) async {
    UserStripeInfo userStripeInfo;
    DocumentSnapshot snapshot = await stripeRef.doc(uid).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      print(snapshot.data());
      userStripeInfo = UserStripeInfo.fromMap(snapshot.data());
    }
    return userStripeInfo;
  }

  ///TODO: CREATE/RENAME CLOUD FUNCTION
  Future<Map<String, dynamic>> getStripeConnectAccountVerificationStatus(String uid) async {
    Map<String, dynamic> res;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'getStripeConnectAccountVerificationStatus',
    );

    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'uid': uid,
    });

    if (result.data != null) {
      res = Map<String, dynamic>.from(result.data);
    }
    return res;
  }

  Future<String> updateStripeAccountVerificationStatus(String uid) async {
    String status = "pending";
    Map<String, dynamic> res = await getStripeConnectAccountVerificationStatus(uid);

    //Check if additional KYC data is required
    List currentlyDue = res['currently_due'];

    //Check if any stripe connect account data is pending verification
    List pending = res['pending_verification'];

    if (currentlyDue.length > 1 || pending.isNotEmpty) {
      await stripeRef.doc(uid).update({"verified": "pending"});
    } else {
      await stripeRef.doc(uid).update({"verified": "verified"});
      status = "verified";
    }
    return status;
  }

  Future<Map<String, dynamic>> getStripeAccountBalance({
    @required String uid,
    @required String stripeUID,
  }) async {
    Map<String, dynamic> res;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'getStripeAccountBalance',
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

  Future<String> performInstantStripePayout({
    @required String uid,
    @required String stripeUID,
  }) async {
    String status;
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

  Future<String> submitBankingInfoToStripe({
    @required String uid,
    @required String stripeUID,
    @required String accountHolderName,
    @required String accountHolderType,
    @required String routingNumber,
    @required String accountNumber,
  }) async {
    String status;
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

  Future<String> submitCardInfoToStripe({
    @required String uid,
    @required String stripeUID,
    @required String cardNumber,
    @required int expMonth,
    @required int expYear,
    @required String cvcNumber,
    @required String cardHolderName,
  }) async {
    String status;
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
}
