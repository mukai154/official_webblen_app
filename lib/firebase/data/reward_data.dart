import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/services/location/location_service.dart';

class RewardDataService {
  final CollectionReference rewardRef = FirebaseFirestore.instance.collection("rewards");
  final CollectionReference purchasedRewardsRef = FirebaseFirestore.instance.collection("purchased_rewards");
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_user");
  final Reference storageReference = FirebaseStorage.instance.ref();
  final double degreeMinMax = 0.145;

  Future<WebblenReward> uploadReward(WebblenReward reward, String zipPostalCode, File imgFile) async {
    List nearbyZipcodes = [];
    String id = reward.id == null ? randomAlphaNumeric(12) : reward.id;
    reward.id = id;
    // reward.webAppLink = 'https://app.webblen.io/#/reward?id=${reward.id}';
    if (imgFile != null) {
      String fileName = "${reward.id}.jpg";
      String imgURL = await uploadRewardImage(imgFile, fileName);
      reward.imageURL = imgURL;
    }
    if (zipPostalCode != null) {
      List listOfAreaCodes = await LocationService().findNearestZipcodes(zipPostalCode);
      if (listOfAreaCodes != null) {
        nearbyZipcodes = listOfAreaCodes;
      } else {
        nearbyZipcodes.add(zipPostalCode);
      }
      reward.nearbyZipcodes = nearbyZipcodes;
    }
    await rewardRef.doc(id).set(reward.toMap());
    return reward;
  }

  Future<String> uploadRewardImage(File imgFile, String fileName) async {
    Reference ref = storageReference.child("rewards").child(fileName);
    UploadTask uploadTask = ref.putFile(imgFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  Future<List<WebblenReward>> findLocalRewards(String zipcode) async {
    List<WebblenReward> rewards = [];

    QuerySnapshot querySnapshot = await rewardRef
        .where(
          'nearbyZipcodes',
          arrayContains: zipcode,
        )
        .get();
    List eventsSnapshot = querySnapshot.docs;
    eventsSnapshot.forEach((rewardDoc) {
      WebblenReward reward = WebblenReward.fromMap(rewardDoc.data);
      rewards.add(reward);
    });
    return rewards;
  }

  Future<List<WebblenReward>> findWebblenMerchRewards() async {
    List<WebblenReward> rewards = [];
    QuerySnapshot snapshot = await rewardRef.where('type', isEqualTo: 'webblenClothes').get().catchError((e) {
      print(e);
    });
    snapshot.docs.forEach((doc) {
      WebblenReward reward = WebblenReward.fromMap(doc.data());
      rewards.add(reward);
    });
    return rewards;
  }

  Future<List<WebblenReward>> findGlobalRewards() async {
    List<WebblenReward> rewards = [];

    QuerySnapshot querySnapshot = await rewardRef
        .where(
          'isGlobalReward',
          isEqualTo: true,
        )
        .get();
    List eventsSnapshot = querySnapshot.docs;
    eventsSnapshot.forEach((rewardDoc) {
      WebblenReward reward = WebblenReward.fromMap(rewardDoc.data);
      rewards.add(reward);
    });
    return rewards;
  }

  Future<List<WebblenReward>> findCashRewards() async {
    List<WebblenReward> rewards = [];

    QuerySnapshot querySnapshot = await rewardRef.where('type', isEqualTo: 'cash').get();
    querySnapshot.docs.forEach((doc) {
      WebblenReward reward = WebblenReward.fromMap(doc.data());
      rewards.add(reward);
    });

    return rewards;
  }

  Future<List<WebblenReward>> findDonationRewards() async {
    List<WebblenReward> rewards = [];

    QuerySnapshot querySnapshot = await rewardRef
        .where(
          'type',
          isEqualTo: 'donation',
        )
        .get();
    List eventsSnapshot = querySnapshot.docs;
    eventsSnapshot.forEach((rewardDoc) {
      WebblenReward reward = WebblenReward.fromMap(rewardDoc.data);
      rewards.add(reward);
    });

    return rewards;
  }

  Future<String> purchaseReward(String uid, double cost) async {
    String error;
    DocumentSnapshot userSnapshot = await userRef.doc(uid).get();
    double userPoints = userSnapshot.data()['d']["eventPoints"] * 1.00;
    if (userPoints < cost) {
      error = "Insufficient Funds";
    } else {
      userPoints = userPoints - cost;
      userRef.doc(uid).update({"d.eventPoints": userPoints}).catchError((e) {
        error = e.details;
      });
    }
    return error;
  }

  Future<String> purchaseMerchReward(
      String uid, String rewardType, String rewardTitle, String rewardID, String size, String email, String address1, String address2) async {
    String error;
    purchasedRewardsRef.doc(uid).set({
      "uid": uid,
      "rewardType": rewardType,
      "rewardTitle": rewardTitle,
      "rewardID": rewardID,
      "size": size,
      "email": email,
      "address1": address1,
      "address2": address2,
      "status": "pending",
      "purchaseTimeInMilliseconds": DateTime.now().millisecondsSinceEpoch,
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> purchaseCashReward(String uid, String rewardType, String rewardTitle, String rewardID, String cashUsername, email) async {
    String error = "";
    purchasedRewardsRef.doc(uid).set({
      "uid": uid,
      "email": email,
      "rewardType": rewardType,
      "rewardTitle": rewardTitle,
      "rewardID": rewardID,
      "cashUsername": cashUsername,
      "status": "pending",
      "purchaseTimeInMilliseconds": DateTime.now().millisecondsSinceEpoch,
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<WebblenReward> findRewardByID(String rewardID) async {
    WebblenReward reward;
    DocumentSnapshot docSnapshot = await rewardRef.doc(rewardID).get();
    if (docSnapshot.exists) {
      reward = WebblenReward.fromMap(docSnapshot.data());
    }
    return reward;
  }

  Future<Null> deleteRewardByID(String rewardID) async {
    DocumentSnapshot docSnapshot = await rewardRef.doc(rewardID).get();
    if (docSnapshot.exists) {
      rewardRef.doc(rewardID).delete();
    }
  }
}
