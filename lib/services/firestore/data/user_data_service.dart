import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/models/webblen_user.dart';

class UserDataService {
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_users');
  CollectionReference stripeRef = FirebaseFirestore.instance.collection('stripe');

  Future checkIfUserExists(String id) async {
    bool exists = false;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      exists = true;
    }
    return exists;
  }

  Future createWebblenUser(WebblenUser user) async {
    await userRef.doc(user.id).set(user.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future getWebblenUserByID(String id) async {
    WebblenUser user;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      user = WebblenUser.fromMap(snapshot.data());
    }
    return user;
  }

  Future updateWebblenUser(WebblenUser user) async {
    await userRef.doc(user.id).update(user.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future getUserStripeInfoByID(String id) async {
    UserStripeInfo userStripeInfo;
    DocumentSnapshot snapshot = await stripeRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      userStripeInfo = UserStripeInfo.fromMap(snapshot.data());
    }
    return userStripeInfo;
  }

  Future<String> depositWebblen(double depositAmount, String uid) async {
    String error;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    WebblenUser user = WebblenUser.fromMap(snapshot.data());
    double initialBalance = user.WBLN == null ? 0.00001 : user.WBLN;
    double newBalance = depositAmount + initialBalance;
    await userRef.doc(uid).update({'WBLN': newBalance}).catchError((e) {
      error = e.toString();
    });
    return error;
  }
}
