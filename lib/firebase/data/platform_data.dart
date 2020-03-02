import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformDataService {
  Future<bool> isUpdateRequired() async {
    bool updateAvailable = false;
    String currentVersion = "9.0.0";
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection("app_release_info").document("general").get();
    String releasedVersion = documentSnapshot.data["versionNumber"];
    bool versionIsRequired = documentSnapshot.data["versionIsRequired"];
    if (currentVersion != releasedVersion && versionIsRequired) {
      updateAvailable = true;
    }
    return updateAvailable;
  }
}
