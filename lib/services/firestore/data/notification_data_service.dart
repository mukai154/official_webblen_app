import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_notification.dart';

class NotificationDataService {
  SnackbarService? _snackbarService = locator<SnackbarService>();
  CollectionReference notifsRef = FirebaseFirestore.instance.collection("webblen_notifications");

  Future<int> getNumberOfUnreadNotifications(String? uid) async {
    int num = 0;
    QuerySnapshot snapshot = await notifsRef.where('receiverUID', isEqualTo: uid).where('read', isEqualTo: false).get();
    if (snapshot.docs.isNotEmpty) {
      num = snapshot.docs.length;
    }
    return num;
  }

  clearNotifications(String? uid) async {
    QuerySnapshot snapshot = await notifsRef.where('receiverUID', isEqualTo: uid).where('read', isEqualTo: false).get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) async {
        await notifsRef.doc(doc.id).update({'read': true}).catchError((e) {
          return e.message;
        });
      });
    }
  }

  Future sendNotification({
    required WebblenNotification notif,
  }) async {
    String notifID = notif.receiverUID! + "-" + notif.timePostedInMilliseconds.toString();
    await notifsRef.doc(notifID).set(notif.toMap()).catchError((e) {
      return e.message;
    });
  }

  ///QUERY DATA
  //Load Notifications
  Future<List<DocumentSnapshot>> loadNotifications({
    required String? uid,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    QuerySnapshot snapshot =
        await notifsRef.where('receiverUID', isEqualTo: uid).orderBy('expDateInMilliseconds', descending: true).limit(15).get().catchError((e) {
      _snackbarService!.showSnackbar(
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

  //Load Additional Notifications
  Future<List<DocumentSnapshot>> loadAdditionalNotifications({
    required String? uid,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    QuerySnapshot snapshot = await notifsRef
        .where('receiverUID', isEqualTo: uid)
        .orderBy('expDateInMilliseconds', descending: true)
        .startAfterDocument(lastDocSnap)
        .limit(15)
        .get()
        .catchError((e) {
      _snackbarService!.showSnackbar(
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
