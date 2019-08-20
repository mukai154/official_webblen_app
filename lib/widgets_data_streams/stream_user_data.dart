import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:webblen/models/webblen_user.dart';

class StreamUserData {

  static Future<StreamSubscription<DocumentSnapshot>> getUserStream(String uid, void onData(WebblenUser user)) async {

    StreamSubscription<DocumentSnapshot> subscription = Firestore.instance
        .collection("webblen_user")
        .document(uid)
        .get()
        .asStream()
        .listen((DocumentSnapshot userDoc){
          Map<String, dynamic> userMap =  Map<String, dynamic>.from(userDoc.data['d']);
          WebblenUser user = WebblenUser.fromMap(userMap);
          onData(user);
    });

    return subscription;
  }

}