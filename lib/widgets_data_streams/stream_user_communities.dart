import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:webblen/models/community.dart';

class StreamUserCommunities {

  static Future<StreamSubscription<DocumentSnapshot>> getUserCommunityStream(String areaName, String comNam, void onData(Community com)) async {

    StreamSubscription<DocumentSnapshot> subscription = Firestore.instance
        .collection("available_locations")
        .document(areaName)
        .collection("communities")
        .document(comNam)
        .get()
        .asStream()
        .listen((DocumentSnapshot comDoc){
      Community com = Community.fromMap(comDoc.data);
      onData(com);
    });

    return subscription;
  }

}