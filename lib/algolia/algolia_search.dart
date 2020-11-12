import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlgoliaSearch {
  final DocumentReference algoliaDocRef = FirebaseFirestore.instance.collection("app_release_info").doc("algolia");

  Future<Algolia> initializeAlgolia() async {
    Algolia algolia;
    String appID;
    String apiKey;
    DocumentSnapshot snapshot = await algoliaDocRef.get();
    appID = snapshot.data()['appID'];
    apiKey = snapshot.data()['apiKey'];
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
        if (snapshot.data['d'] != null) {
          Map<String, dynamic> dataMap = {};
          dataMap['resultType'] = 'user';
          dataMap['resultHeader'] = "@" + snapshot.data['d']['username'];
          dataMap['imageData'] = snapshot.data['d']['profile_pic'];
          dataMap['key'] = snapshot.data['d']['uid'];
          results.add(dataMap);
        }
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
        if (snapshot.data != null) {
          Map<String, dynamic> dataMap = {};
          dataMap['resultType'] = 'event';
          dataMap['resultHeader'] = snapshot.data['title'];
          dataMap['imageData'] = snapshot.data['imageURL'];
          dataMap['key'] = snapshot.data['id'];
          results.add(dataMap);
        }
      });
    }
    return results;
  }

  Future<List<String>> queryTags(String searchTerm) async {
    Algolia algolia = await initializeAlgolia();
    List<String> results = [];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('tags').search(searchTerm);
      AlgoliaQuerySnapshot snapshot = await query.getObjects();
      snapshot.hits.forEach((snapshot) {
        // print(searchTerm);
        // print(snapshot.data);
        if (snapshot.data != null) {
          String res = snapshot.data['tag'];
          results.add(res);
        }
      });
    }
    return results;
  }

  Future<Map<dynamic, dynamic>> getTagsAndCategories() async {
    Map<dynamic, dynamic> allTags = {};
    Algolia algolia = await initializeAlgolia();
    AlgoliaQuerySnapshot q = await algolia.instance.index('tags').getObjects();
    q.hits.forEach((snapshot) {
      Map<String, dynamic> data = snapshot.data;
      if (allTags[data['category']] == null) {
        allTags[data['category']] = [data['tag']];
      } else {
        allTags[data['category']].add(data['tag']);
      }
    });
    allTags.forEach((key, value) {
      List tags = value.toList(growable: true);
      tags.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      allTags[key] = tags;
    });
    return allTags;
  }
}
