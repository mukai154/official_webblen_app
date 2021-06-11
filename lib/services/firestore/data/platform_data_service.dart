import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformDataService {
  CollectionReference appReleaseRef = FirebaseFirestore.instance.collection("app_release_info");
  CollectionReference webblenCurrencyRef = FirebaseFirestore.instance.collection("webblen_currency");

  Future<bool> isUpdateAvailable() async {
    bool updateAvailable = false;
    String currentVersion = "10.1.1";
    DocumentSnapshot snapshot = await appReleaseRef.doc("general").get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    String? releasedVersion = snapshotData["versionNumber"];
    bool? versionIsRequired = snapshotData["versionIsRequired"];
    if (currentVersion != releasedVersion && versionIsRequired!) {
      updateAvailable = true;
    }
    return updateAvailable;
  }

  Future<bool> isUnderMaintenance() async {
    bool underMaintenance = false;
    DocumentSnapshot snapshot = await appReleaseRef.doc("general").get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    underMaintenance = snapshotData["underMaintenance"];
    return underMaintenance;
  }

  ///NEW CONTENT RATES
  Future<double?> getNewPostTaxRate() async {
    double? promo;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_ECONOMY').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      promo = snapshotData['newPostTaxRate'].toDouble();
    } catch (e) {}
    return promo;
  }

  Future<double?> getNewStreamTaxRate() async {
    double? promo;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_ECONOMY').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      promo = snapshotData['newStreamTaxRate'].toDouble();
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   title: 'Promotion Error',
      //   message: "There Was an Issue Getting Webblen Promotions",
      //   duration: Duration(seconds: 5),
      // );
    }
    return promo;
  }

  Future<double?> getNewEventTaxRate() async {
    double? promo;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_ECONOMY').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      promo = snapshotData['newEventTaxRate'].toDouble();
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   title: 'Promotion Error',
      //   message: "There Was an Issue Getting Webblen Promotions",
      //   duration: Duration(seconds: 5),
      // );
    }
    return promo;
  }

  Future<double> getNewAccountReward() async {
    double val = 1.001;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_ECONOMY').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      val = snapshotData['newAccountReward'].toDouble();
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   title: 'Promotion Error',
      //   message: "There Was an Issue Getting Webblen Promotions",
      //   duration: Duration(seconds: 5),
      // );
    }
    return val;
  }

  ///PROMOTIONS
  Future<double?> getPostPromo() async {
    double? promo;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_INCENTIVES').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      promo = snapshotData['postPromo'].toDouble();
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   title: 'Promotion Error',
      //   message: "There Was an Issue Getting Webblen Promotions",
      //   duration: Duration(seconds: 5),
      // );
    }
    return promo;
  }

  Future<double?> getStreamPromo() async {
    double? promo;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_INCENTIVES').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      promo = snapshotData['streamPromo'].toDouble();
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   title: 'Promotion Error',
      //   message: "There Was an Issue Getting Webblen Promotions",
      //   duration: Duration(seconds: 5),
      // );
    }
    return promo;
  }

  Future<double> getEventPromo() async {
    double promo = 0;
    DocumentSnapshot snapshot = await webblenCurrencyRef.doc('APP_INCENTIVES').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    try {
      promo = snapshotData['eventPromo'].toDouble();
    } catch (e) {
      // _snackbarService.showSnackbar(
      //   title: 'Promotion Error',
      //   message: "There Was an Issue Getting Webblen Promotions",
      //   duration: Duration(seconds: 5),
      // );
    }
    return promo;
  }

  Future<double> getEventTicketFee() async {
    double eventTicketFee = 0;
    DocumentSnapshot snapshot = await appReleaseRef.doc('general').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    eventTicketFee = snapshotData['ticketFee'];
    return eventTicketFee;
  }

  Future<double> getTaxRate() async {
    double taxRate = 0;
    DocumentSnapshot snapshot = await appReleaseRef.doc('general').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    taxRate = snapshotData['taxRate'];
    return taxRate;
  }

  Future<String?> getWebblenDownloadLink() async {
    String? key;
    DocumentSnapshot snapshot = await appReleaseRef.doc('webblen').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    key = snapshotData['downloadLink'];
    return key;
  }

  Future<String> getStripePubKey() async {
    String pubKey = "";
    DocumentSnapshot snapshot = await appReleaseRef.doc('stripe').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    if (snapshotData['underMaintenance']) {
      pubKey = snapshotData['testPubKey'];
    } else {
      pubKey = snapshotData['pubKey'];
    }
    return pubKey;
  }

  Future<String?> getSendGridApiKey() async {
    String? appID;
    DocumentSnapshot snapshot = await appReleaseRef.doc('sendgrid').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    appID = snapshotData['apiKey'];
    return appID;
  }

  Future<String?> getSendGridTicketTemplateID() async {
    String? appID;
    DocumentSnapshot snapshot = await appReleaseRef.doc('sendgrid').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    appID = snapshotData['ticketEmailTemplateID'];
    return appID;
  }

  Future<String?> getAgoraAppID() async {
    String? appID;
    DocumentSnapshot snapshot = await appReleaseRef.doc('agora').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    appID = snapshotData['appID'];
    return appID;
  }

  Future<String?> getGoogleApiKey() async {
    String? key;
    DocumentSnapshot snapshot = await appReleaseRef.doc('google').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    key = snapshotData['apiKey'];
    return key;
  }

  Future<String> getPlatformLogoURL() async {
    String url = '';
    DocumentSnapshot snapshot = await appReleaseRef.doc('general').get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    url = snapshotData['logoURL'];
    return url;
  }
}
