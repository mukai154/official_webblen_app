import 'package:algolia/algolia.dart';

final Algolia algolia = Algolia.init(
  applicationId: '5WGDZA0Z6Z',
  apiKey: '6e3077d3ad170d533f04106836e26405',
);

class AlgoliaSearch {
  Future<List<Map<String, dynamic>>> queryEvents(String searchTerm) async {
    List<Map<String, dynamic>> results = [];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      AlgoliaQuery query =
          algolia.instance.index('upcoming_events').search(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        Map<String, dynamic> dataMap = {};
        dataMap['resultType'] = 'event';
        dataMap['resultHeader'] = snapshot.data['d']['title'];
        dataMap['imageData'] = snapshot.data['d']['imageURL'];
        dataMap['communityData'] = snapshot.data['d']['communityAreaName'] +
            "/" +
            snapshot.data['d']['communityName'];
        dataMap['key'] = snapshot.data['d']['eventKey'];
        results.add(dataMap);
      });
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> queryCommunities(String searchTerm) async {
    List<Map<String, dynamic>> results = [];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      AlgoliaQuery query =
          algolia.instance.index('communities').search(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        Map<String, dynamic> dataMap = {};
        dataMap['resultType'] = 'community';
        dataMap['resultHeader'] = snapshot.data['name'];
        dataMap['imageData'] = snapshot.data['comImageURL'];
        dataMap['data'] = snapshot.data['areaName'];
        results.add(dataMap);
      });
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> queryUsers(String searchTerm) async {
    List<Map<String, dynamic>> results = [];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('users').search(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        Map<String, dynamic> dataMap = {};
        dataMap['resultType'] = 'people';
        dataMap['resultHeader'] = "@" + snapshot.data['d']['username'];
        dataMap['imageData'] = snapshot.data['d']['profile_pic'];
        dataMap['key'] = snapshot.data['d']['uid'];
        results.add(dataMap);
      });
    }
    return results;
  }
}
