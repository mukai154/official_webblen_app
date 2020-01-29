import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

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
}
