import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';

class RedeemedRewardDataService {
  CollectionReference purchasedRewardsRef =
      FirebaseFirestore.instance.collection('purchased_rewards');
  SnackbarService _snackbarService = locator<SnackbarService>();

  //Load Comments Created
  Future<List<DocumentSnapshot>> loadUserRedeemedRewards({
    @required String uid,
    @required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = purchasedRewardsRef
        .where('uid', isEqualTo: uid)
        .orderBy('timePostedInMilliseconds', descending: true)
        .limit(resultsLimit);

    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
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

  //Load Additional Causes by Follower Count
  Future<List<DocumentSnapshot>> loadAdditionalUserRedeemedRewards({
    @required String uid,
    @required DocumentSnapshot lastDocSnap,
    @required int resultsLimit,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    query = purchasedRewardsRef
        .where('uid', isEqualTo: uid)
        .orderBy('timePostedInMilliseconds', descending: true)
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
