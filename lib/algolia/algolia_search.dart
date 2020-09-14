import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlgoliaSearch {
  DocumentReference algoliaDocRef = Firestore().collection("app_release_info").document("algolia");

  Future<Algolia> initializeAlgolia() async {
    Algolia algolia;
    String appID;
    String apiKey;
    DocumentSnapshot snapshot = await algoliaDocRef.get();
    appID = snapshot.data['appID'];
    apiKey = snapshot.data['apiKey'];
    algolia = Algolia.init(applicationId: appID, apiKey: apiKey);
    return algolia;
  }

  Future<List<Map<String, dynamic>>> queryUsers(String searchTerm) async {
    Algolia algolia = await initializeAlgolia();
    List<Map<String, dynamic>> results = [];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('users').search(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        Map<String, dynamic> dataMap = {};
        dataMap['resultType'] = 'user';
        dataMap['resultHeader'] = "@" + snapshot.data['d']['username'];
        dataMap['imageData'] = snapshot.data['d']['profile_pic'];
        dataMap['key'] = snapshot.data['d']['uid'];
        results.add(dataMap);
      });
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> queryEvents(String searchTerm) async {
    Algolia algolia = await initializeAlgolia();
    List<Map<String, dynamic>> results = [];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('events').search(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        Map<String, dynamic> dataMap = {};
        dataMap['resultType'] = 'event';
        dataMap['resultHeader'] = snapshot.data['title'];
        dataMap['imageData'] = snapshot.data['imageURL'];
        dataMap['key'] = snapshot.data['id'];
        results.add(dataMap);
      });
    }
    return results;
  }
}
