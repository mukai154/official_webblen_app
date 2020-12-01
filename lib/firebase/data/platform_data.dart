import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformDataService {
  CollectionReference appReleaseRef = FirebaseFirestore.instance.collection("app_release_info");

  Future<bool> isUpdateAvailable() async {
    bool updateAvailable = false;
    String currentVersion = "9.2.0";
    DocumentSnapshot docSnapshot = await appReleaseRef.doc("general").get();
    String releasedVersion = docSnapshot.data()["versionNumber"];
    bool versionIsRequired = docSnapshot.data()["versionIsRequired"];
    if (currentVersion != releasedVersion && versionIsRequired) {
      updateAvailable = true;
    }
    return updateAvailable;
  }

  Future<double> getEventTicketFee() async {
    double eventTicketFee;
    DocumentSnapshot snapshot = await appReleaseRef.doc('general').get();
    eventTicketFee = snapshot.data()['ticketFee'];
    return eventTicketFee;
  }

  Future<double> getTaxRate() async {
    double taxRate;
    DocumentSnapshot snapshot = await appReleaseRef.doc('general').get();
    taxRate = snapshot.data()['taxRate'];
    return taxRate;
  }

  Future<String> getStripePubKey() async {
    String pubKey;
    DocumentSnapshot snapshot = await appReleaseRef.doc('stripe').get();
    pubKey = snapshot.data()['pubKey'];
    return pubKey;
  }

  Future<String> getAgoraAppID() async {
    String appID;
    DocumentSnapshot snapshot = await appReleaseRef.doc('agora').get();
    appID = snapshot.data()['appID'];
    return appID;
  }

  Future<String> getGoogleApiKey() async {
    String appID;
    DocumentSnapshot snapshot = await appReleaseRef.doc('google').get();
    appID = snapshot.data()['apiKey'];
    return appID;
  }
}
