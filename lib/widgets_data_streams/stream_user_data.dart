import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:webblen/models/webblen_user.dart';

class StreamUserData {

  static Future<StreamSubscription<DocumentSnapshot>> getUserStream(String uid, void onData(WebblenUser user)) async {

    StreamSubscription<DocumentSnapshot> subscription = Firestore.instance
        .collection("users")
        .document(uid)
        .get()
        .asStream()
        .listen((DocumentSnapshot userDoc){
        WebblenUser user = WebblenUser.fromMap(userDoc.data);
        onData(user);
    });

    return subscription;
  }

}