import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user.dart';

class UserDataService {
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_user');

  Future checkIfUserExists(String id) async {
    bool exists = false;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      exists = true;
    }
    return exists;
  }

  Future createWebblenUser(WebblenUser user) async {
    await userRef.doc(user.uid).set(user.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future getWebblenUserByID(String id) async {
    WebblenUser user;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data();
      user = WebblenUser.fromMap(snapshotData['d']);
    }
    return user;
  }

  Future updateWebblenUser(WebblenUser user) async {
    await userRef.doc(user.uid).update(user.toMap()).catchError((e) {
      return e.message;
    });
  }
}
