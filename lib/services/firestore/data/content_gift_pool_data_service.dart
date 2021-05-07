import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_content_gift_pool.dart';
import 'package:webblen/models/webblen_user.dart';

class ContentGiftPoolDataService {
  CollectionReference giftPoolRef = FirebaseFirestore.instance.collection('webblen_content_gift_pools');
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_users');
  SnackbarService? _snackbarService = locator<SnackbarService>();

  Future<bool> checkIfGiftPoolExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await giftPoolRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      _snackbarService!.showSnackbar(
        title: 'Error',
        message: e.toString(),
        duration: Duration(seconds: 5),
      );
      return false;
    }
    return exists;
  }

  Future createGiftPool(WebblenContentGiftPool giftPool) async {
    await giftPoolRef.doc(giftPool.id).set(giftPool.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future<WebblenContentGiftPool> getGiftPoolByID(String? id) async {
    WebblenContentGiftPool giftPool = WebblenContentGiftPool();
    String? error;
    DocumentSnapshot snapshot = await giftPoolRef.doc(id).get().catchError((e) {
      error = e.message;
    });

    if (error != null) {
      print(error);
      return giftPool;
    }

    if (snapshot.exists) {
      giftPool = WebblenContentGiftPool.fromMap(snapshot.data()!);
    }
    return giftPool;
  }

  Future<bool> updateGiftPool(WebblenContentGiftPool giftPool) async {
    await giftPoolRef.doc(giftPool.id).update(giftPool.toMap()).catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Gift Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return false;
    });
    return true;
  }

  Future<bool> addToGiftPool({String? giftPoolID, String? uid, double? amount, int? giftID}) async {
    //get gift pool
    WebblenContentGiftPool giftPool = await getGiftPoolByID(giftPoolID);
    Map<dynamic, dynamic> gifters = giftPool.gifters!;

    //get user
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    WebblenUser user = WebblenUser.fromMap(snapshot.data()!);

    //add to gift pool
    if (gifters[uid] == null) {
      gifters[uid] = {'uid': uid, 'username': user.username, 'userImgURL': user.profilePicURL, 'totalGiftAmount': amount};
    } else {
      Map<String, dynamic> gifter = gifters[uid];
      double prevGiftAmount = gifter['totalGiftAmount'];
      double newGiftAmount = prevGiftAmount + amount!;
      gifters[uid] = {'uid': uid, 'username': user.username, 'userImgURL': user.profilePicURL, 'totalGiftAmount': newGiftAmount};
    }

    giftPool.gifters = gifters;
    giftPool.totalGiftAmount = giftPool.totalGiftAmount == null ? amount : giftPool.totalGiftAmount! + amount!;

    bool updatedGiftPool = await updateGiftPool(giftPool);

    if (updatedGiftPool) {
      int timePostedInMilliseconds = DateTime.now().millisecondsSinceEpoch;
      //log donation
      giftPoolRef.doc(giftPoolID).collection('logs').doc(timePostedInMilliseconds.toString()).set({
        'senderUsername': user.username,
        'message': "@${user.username}\nGifted $amount WBLN",
        'giftID': giftID,
        'timePostedInMilliseconds': timePostedInMilliseconds,
      });
      //Update user balance;
      double initialBalance = user.WBLN == null ? 0.00001 : user.WBLN!;
      double newBalance = initialBalance - amount!;
      await userRef.doc(uid).update({"WBLN": newBalance}).catchError((e) {
        print(e.message);
        //error = e.toString();
      });
    }

    return true;
  }
}
