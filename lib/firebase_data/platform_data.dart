import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformDataService {
  CollectionReference appReleaseRef = Firestore().collection("app_release_info");

  Future<bool> isUpdateAvailable() async {
    bool updateAvailable = false;
    String currentVersion = "9.0.1";
    DocumentSnapshot documentSnapshot = await appReleaseRef.document("general").get();
    String releasedVersion = documentSnapshot.data["versionNumber"];
    bool versionIsRequired = documentSnapshot.data["versionIsRequired"];
    if (currentVersion != releasedVersion && versionIsRequired) {
      updateAvailable = true;
    }
    return updateAvailable;
  }

  Future<double> getEventTicketFee() async {
    double eventTicketFee;
    DocumentSnapshot snapshot = await appReleaseRef.document('general').get();
    eventTicketFee = snapshot.data['ticketFee'];
    return eventTicketFee;
  }

  Future<double> getTaxRate() async {
    double taxRate;
    DocumentSnapshot snapshot = await appReleaseRef.document('general').get();
    taxRate = snapshot.data['taxRate'];
    return taxRate;
  }

  Future<String> getStripePubKey() async {
    String pubKey;
    DocumentSnapshot snapshot = await appReleaseRef.document('stripe').get();
    pubKey = snapshot.data['pubKey'];
    return pubKey;
  }

  Future<String> getAgoraAppID() async {
    String appID;
    DocumentSnapshot snapshot = await appReleaseRef.document('agora').get();
    appID = snapshot.data['appID'];
    return appID;
  }
}
