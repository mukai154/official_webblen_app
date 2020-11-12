import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/services/location/location_service.dart';

class RewardDataService {
  final CollectionReference rewardRef = FirebaseFirestore.instance.collection("rewards");
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

  Future<String> updateAmountOfRewardAvailable(String rewardID) async {
    String status = "";
    DocumentSnapshot docSnapshot = await rewardRef.doc(rewardID).get();
    int amountAvailable = docSnapshot.data()["amountAvailable"];
    if (amountAvailable > 0) {
      amountAvailable -= 1;
    }
    rewardRef.doc(rewardID).update({"amountAvailable": amountAvailable}).whenComplete(() {
      status = amountAvailable.toString();
    }).catchError((e) {
      status = "error";
    });
    return status;
  }

  Future<String> purchaseReward(String uid, String rewardID, double cost) async {
    String error = "";
    DocumentSnapshot userSnapshot = await userRef.doc(uid).get();
    double userPoints = userSnapshot.data()['d']["eventPoints"] * 1.00;
    List userRewards = userSnapshot.data()['d']["rewards"].toList();
    if (userPoints < cost) {
      error = "Insufficient Funds";
    } else if (userRewards.contains(rewardID)) {
      error = "Reward Already Purchased";
    } else {
      userRewards.add(rewardID);
      userPoints = userPoints - cost;
      userRef.doc(uid).update({"d.eventPoints": userPoints, "d.rewards": userRewards}).whenComplete(() {}).catchError((e) {
            error = e.details;
          });
    }
    return error;
  }

  Future<String> removeUserReward(String uid, String rewardID) async {
    String error = "";
    DocumentSnapshot userSnapshot = await userRef.doc(uid).get();
    List userRewards = userSnapshot.data()['d']["rewards"].toList();
    userRewards.remove(rewardID);
    userRef.doc(uid).update({"d.rewards": userRewards}).whenComplete(() {}).catchError((e) {
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

  Future<List<WebblenReward>> deleteExpiredRewards(List<WebblenReward> rewardsList) async {
    DateFormat formatter = new DateFormat("MM/dd/yyyy");
    DateTime today = DateTime.now();
    List<WebblenReward> validRewards = rewardsList.toList(
      growable: true,
    );
    rewardsList.forEach((reward) {
      DateTime rewardExpirationDate = formatter.parse(reward.expirationDate);
      if (today.isAfter(rewardExpirationDate)) {
        rewardRef.doc(reward.id).delete();
        validRewards.remove(reward);
      }
    });
    return validRewards;
  }

  filterRewards(List<WebblenReward> rewardsList, double filterCost, String filterType) {
    List<WebblenReward> filteredRewards;
    filteredRewards = rewardsList.where((reward) => reward.type == filterType).toList();
    return filteredRewards;
  }
}
