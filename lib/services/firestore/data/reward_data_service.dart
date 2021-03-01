import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/reward_status.dart';
import 'package:webblen/enums/reward_type.dart';

class RewardDataService {
  CollectionReference rewardsRef =
      FirebaseFirestore.instance.collection('rewards');
  CollectionReference purchasedRewardsRef =
      FirebaseFirestore.instance.collection('purchased_rewards');
  CollectionReference userRef =
      FirebaseFirestore.instance.collection('webblen_users');
  SnackbarService _snackbarService = locator<SnackbarService>();

  Future<String> purchaseReward(String uid, double cost) async {
    String error;
    DocumentSnapshot userSnapshot = await userRef.doc(uid).get();
    double userPoints = userSnapshot.data()['WBLN'] * 1.00;
    if (userPoints < cost) {
      error = "Insufficient Funds";
    } else {
      userPoints = userPoints - cost;
      userRef.doc(uid).update({"WBLN": userPoints}).catchError((e) {
        error = e.details;
      });
    }
    return error;
  }

  Future<String> purchaseMerchReward({
    String uid,
    String rewardTitle,
    String rewardID,
    String size,
    String email,
    String address1,
    String address2,
  }) async {
    String error;
    DocumentReference newDocRef = purchasedRewardsRef.doc();
    newDocRef.set({
      'id': newDocRef.id,
      "uid": uid,
      "rewardType":
          RewardTypeConverter.rewardTypeToString(RewardType.webblenClothes),
      "rewardTitle": rewardTitle,
      "rewardID": rewardID,
      "size": size,
      "email": email,
      "address1": address1,
      "address2": address2,
      "status":
          RewardStatusConverter.rewardStatusToString(RewardStatus.pending),
      "purchaseTimeInMilliseconds": DateTime.now().millisecondsSinceEpoch,
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> purchaseCashReward({
    String uid,
    String rewardTitle,
    String rewardID,
    String cashUsername,
    String email,
  }) async {
    String error = "";
    DocumentReference newDocRef = purchasedRewardsRef.doc();
    newDocRef.set({
      'id': newDocRef.id,
      "uid": uid,
      "email": email,
      "rewardType": RewardTypeConverter.rewardTypeToString(RewardType.cash),
      "rewardTitle": rewardTitle,
      "rewardID": rewardID,
      "cashUsername": cashUsername,
      "status":
          RewardStatusConverter.rewardStatusToString(RewardStatus.pending),
      "purchaseTimeInMilliseconds": DateTime.now().millisecondsSinceEpoch,
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  //READ DATA
  //Load All Rewards
  Future<List<DocumentSnapshot>> loadRewards({
    @required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = rewardsRef.limit(resultsLimit);

    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return docs;
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  //Load Rewards By Type
  Future<List<DocumentSnapshot>> loadRewardsByType({
    @required RewardType rewardType,
    @required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = rewardsRef
        .where('type',
            isEqualTo: RewardTypeConverter.rewardTypeToString(rewardType))
        .limit(resultsLimit);

    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return docs;
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  //Load Additional Rewards
  Future<List<DocumentSnapshot>> loadAdditionalRewards({
    @required DocumentSnapshot lastDocSnap,
    @required int resultsLimit,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    query = rewardsRef.startAfterDocument(lastDocSnap).limit(resultsLimit);

    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  //Load Additional Rewards By Type
  Future<List<DocumentSnapshot>> loadAdditionalRewardsByType({
    @required RewardType rewardType,
    @required DocumentSnapshot lastDocSnap,
    @required int resultsLimit,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    query = rewardsRef
        .where('type',
            isEqualTo: RewardTypeConverter.rewardTypeToString(rewardType))
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);

    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }
}
