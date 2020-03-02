import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user.dart';

class WebblenUserData {
  final CollectionReference userRef = Firestore.instance.collection("webblen_user");
  final CollectionReference eventRef = Firestore.instance.collection("events");
  final CollectionReference notifRef = Firestore.instance.collection("user_notifications");

  Stream<WebblenUser> streamCurrentUser(String uid) {
    return userRef.document(uid).snapshots().map((snapshot) => WebblenUser.fromMap(Map<String, dynamic>.from(snapshot.data['d'])));
  }

  Future<String> setUserCloudMessageToken(String uid, String messageToken) async {
    String status = "";
    userRef.document(uid).updateData({"d.messageToken": messageToken}).whenComplete(() {}).catchError((e) {
          status = e.details;
        });
    return status;
  }
}
