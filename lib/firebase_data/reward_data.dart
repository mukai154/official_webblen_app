import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';

class RewardDataService {

  final CollectionReference rewardRef = Firestore.instance.collection("rewards");
  final CollectionReference userRef = Firestore.instance.collection("webblen_user");
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final double degreeMinMax = 0.145;

  Future<String> uploadReward(File rewardImage, WebblenReward reward) async {
    String result;
    final String rewardKey = "${Random().nextInt(999999999)}";
    if (rewardImage != null){
      String fileName = "$rewardKey.jpg";
      String downloadUrl = await uploadRewardImage(rewardImage, fileName);
      reward.rewardImagePath = downloadUrl;
    }
    reward.rewardKey = rewardKey;
    await Firestore.instance.collection("rewards").document(rewardKey).setData(reward.toMap()).whenComplete(() {
      result = "success";
    }).catchError((e) {
      result = e.toString();
    });
    return result;
  }

  Future<String> uploadRewardImage(File rewardImage, String fileName) async {
    StorageReference ref = storageReference.child("rewards").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(rewardImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }


  Future<List<WebblenReward>> findTierRewards(String tier) async {
    List<WebblenReward> tierRewards = [];

    QuerySnapshot querySnapshot = await rewardRef
        .where('rewardCategory', isEqualTo: tier)
        .getDocuments();
    List eventsSnapshot = querySnapshot.documents;
    eventsSnapshot.forEach((rewardDoc){
      WebblenReward reward = WebblenReward.fromMap(rewardDoc.data);
      tierRewards.add(reward);
    });
    return tierRewards;
  }

  Future<List<WebblenReward>> findCharityRewards() async {
    List<WebblenReward> charityRewards = [];

    QuerySnapshot querySnapshot = await rewardRef
        .where('rewardCategory', isEqualTo: 'charity')
        .getDocuments();
    List eventsSnapshot = querySnapshot.documents;
    eventsSnapshot.forEach((rewardDoc){
      WebblenReward reward = WebblenReward.fromMap(rewardDoc.data);
      charityRewards.add(reward);
    });

    return charityRewards;
  }

  Future<String> updateAmountOfRewardAvailable(String rewardID) async {
    String status = "";
    DocumentSnapshot documentSnapshot = await rewardRef.document(rewardID).get();
    int amountAvailable = documentSnapshot.data["amountAvailable"];
    if (amountAvailable > 0){
      amountAvailable -= 1;
    }
    rewardRef.document(rewardID).updateData({"amountAvailable": amountAvailable}).whenComplete((){
      status = amountAvailable.toString();
    }).catchError((e) {
      status = "error";
    });
    return status;
  }

  Future<String> purchaseReward(String uid, String rewardID, double cost) async {
    String error = "";
    DocumentSnapshot userSnapshot = await userRef.document(uid).get();
    double userPoints = userSnapshot.data['d']["eventPoints"] * 1.00;
    List userRewards = userSnapshot.data['d']["rewards"].toList();
    if (userPoints < cost){
      error = "Insufficient Funds";
    } else if (userRewards.contains(rewardID)){
      error = "Reward Already Purchased";
    } else {
      userRewards.add(rewardID);
      userPoints = userPoints - cost;
      userRef.document(uid).updateData({"d.eventPoints": userPoints, "d.rewards": userRewards}).whenComplete((){
      }).catchError((e) {
        error = e.details;
      });
    }
    return error;
  }

  Future<String> removeUserReward(String uid, String rewardID) async {
    String error = "";
    DocumentSnapshot userSnapshot = await userRef.document(uid).get();
    List userRewards = userSnapshot.data['d']["rewards"].toList();
    userRewards.remove(rewardID);
    userRef.document(uid).updateData({"d.rewards": userRewards}).whenComplete((){

    }).catchError((e) {
      error = e.details;
    });

    return error;
  }

  Future<WebblenReward> findRewardByID(String rewardID) async {
    WebblenReward reward;
    DocumentSnapshot documentSnapshot = await rewardRef.document(rewardID).get();
    if (documentSnapshot.exists){
      reward = WebblenReward.fromMap(documentSnapshot.data);
    }
    return reward;
  }

  Future<Null> deleteRewardByID(String rewardID) async {
    DocumentSnapshot documentSnapshot = await rewardRef.document(rewardID).get();
    if (documentSnapshot.exists){
      rewardRef.document(rewardID).delete();
    }
  }

  Future<List<WebblenReward>> deleteExpiredRewards(List<WebblenReward> rewardsList) async {
    DateFormat formatter = new DateFormat("MM/dd/yyyy");
    DateTime today = DateTime.now();
    List<WebblenReward> validRewards = rewardsList.toList(growable: true);
    rewardsList.forEach((reward){
      DateTime rewardExpirationDate = formatter.parse(reward.expirationDate);
      if (today.isAfter(rewardExpirationDate)){
        rewardRef.document(reward.rewardKey).delete();
        validRewards.remove(reward);
      }
    });
    return validRewards;
  }

  filterRewards(List<WebblenReward> rewardsList, double filterCost, String filterCategory){
    List<WebblenReward> filteredRewards;
    filteredRewards = rewardsList.where((reward) => reward.rewardCategory == filterCategory).toList();
    return filteredRewards;
  }

}