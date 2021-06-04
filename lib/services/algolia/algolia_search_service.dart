import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/search_result.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';

class AlgoliaSearchService {
  final DocumentReference algoliaDocRef = FirebaseFirestore.instance.collection("app_release_info").doc("algolia");
  final CollectionReference userDocRef = FirebaseFirestore.instance.collection("webblen_users");

  Future<Algolia> initializeAlgolia() async {
    Algolia algolia;
    String? appID;
    String? apiKey;
    DocumentSnapshot snapshot = await algoliaDocRef.get();
    appID = snapshot.data()!['appID'];
    apiKey = snapshot.data()!['apiKey'];
    algolia = Algolia.init(applicationId: appID!, apiKey: apiKey!);
    return algolia;
  }

  Future<List<SearchResult>> searchUsers({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<SearchResult> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_users').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        SearchResult result = SearchResult(
          id: snapshot.data['id'],
          type: 'user',
          name: snapshot.data['username'],
          additionalData: snapshot.data['profilePicURL'],
        );
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenUser>> queryUsers({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenUser> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_users').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenUser result = WebblenUser.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenUser>> queryAdditionalUsers({required String searchTerm, required int resultsLimit, required int pageNum}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenUser> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_users').setHitsPerPage(resultsLimit).setPage(pageNum).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenUser result = WebblenUser.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenUser>> queryUsersByFollowers({required String searchTerm, required String? uid}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenUser> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_users').query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenUser result = WebblenUser.fromMap(snapshot.data);
        if (result.following!.contains(uid)) {
          results.add(result);
        }
      });
    }
    return results;
  }

  Future<List<WebblenUser>> queryUsersByFollowing({required String searchTerm, required String? uid}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenUser> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_users').query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenUser result = WebblenUser.fromMap(snapshot.data);
        if (result.followers!.contains(uid)) {
          results.add(result);
        }
      });
    }
    return results;
  }

  Future<List<WebblenUser>> queryAdditionalUsersByFollowing({
    required String searchTerm,
    required int resultsLimit,
    required String uid,
    required int pageNum,
  }) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenUser> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_users').setHitsPerPage(resultsLimit).setPage(pageNum).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenUser result = WebblenUser.fromMap(snapshot.data);
        if (result.followers!.contains(uid)) {
          results.add(result);
        }
      });
    }
    return results;
  }

  Future<List<SearchResult>> searchPosts({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<SearchResult> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_posts').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        SearchResult result = SearchResult(
          id: snapshot.data['id'],
          type: 'post',
          name: snapshot.data['title'],
          additionalData: null,
        );
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenPost>> queryPosts({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenPost> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_posts').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenPost result = WebblenPost.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenPost>> queryAdditionalPosts({required String searchTerm, required int resultsLimit, required int pageNum}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenPost> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('posts').setHitsPerPage(resultsLimit).setPage(pageNum).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenPost result = WebblenPost.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<SearchResult>> searchEvents({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<SearchResult> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_events').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        SearchResult result = SearchResult(
          id: snapshot.data['id'],
          type: 'event',
          name: snapshot.data['title'],
          additionalData: null,
        );
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenEvent>> queryEvents({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenEvent> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_events').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenEvent result = WebblenEvent.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenEvent>> queryAdditionalEvents({required String searchTerm, required int resultsLimit, required int pageNum}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenEvent> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_events').setHitsPerPage(resultsLimit).setPage(pageNum).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenEvent result = WebblenEvent.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<SearchResult>> searchStreams({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<SearchResult> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_live_streams').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        SearchResult result = SearchResult(
          id: snapshot.data['id'],
          type: 'stream',
          name: snapshot.data['title'],
          additionalData: null,
        );
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenLiveStream>> queryStreams({required String searchTerm, required resultsLimit}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenLiveStream> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_live_streams').setHitsPerPage(resultsLimit).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenLiveStream result = WebblenLiveStream.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  Future<List<WebblenLiveStream>> queryAdditionalStreams({required String searchTerm, required int resultsLimit, required int pageNum}) async {
    Algolia algolia = await initializeAlgolia();
    List<WebblenLiveStream> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('webblen_live_streams').setHitsPerPage(resultsLimit).setPage(pageNum).query(searchTerm);
      AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
      eventsSnapshot.hits.forEach((snapshot) {
        WebblenLiveStream result = WebblenLiveStream.fromMap(snapshot.data);
        results.add(result);
      });
    }
    return results;
  }

  // Future<List<WebblenUser>> queryForYou({@required String zip, @required String tag, @required resultsLimit}) async {
  //   Algolia algolia = await initializeAlgolia();
  //   List<WebblenUser> results = [];
  //   if (searchTerm.isNotEmpty) {
  //     AlgoliaQuery postsQuery = algolia.instance.index('posts').setHitsPerPage(resultsLimit).query(searchTerm);
  //     AlgoliaQuery eventsQuery = algolia.instance.index('webblen_events').setHitsPerPage(resultsLimit).query(searchTerm);
  //     AlgoliaQuery streamsQuery = algolia.instance.index('webblen_streams').setHitsPerPage(resultsLimit).query(searchTerm);
  //     AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
  //     eventsSnapshot.hits.forEach((snapshot) {
  //       if (snapshot.data != null) {
  //         WebblenUser result = WebblenUser.fromMap(snapshot.data);
  //         results.add(result);
  //       }
  //     });
  //   }
  //   return results;
  // }

  // Future<List<WebblenUser>> queryAdditionalForYou({@required String searchTerm, @required int resultsLimit, @required int pageNum}) async {
  //   Algolia algolia = await initializeAlgolia();
  //   List<WebblenUser> results = [];
  //   if (searchTerm.isNotEmpty) {
  //     AlgoliaQuery query = algolia.instance.index('webblen_users').setHitsPerPage(resultsLimit).setPage(pageNum).query(searchTerm);
  //     AlgoliaQuerySnapshot eventsSnapshot = await query.getObjects();
  //     eventsSnapshot.hits.forEach((snapshot) {
  //       if (snapshot.data != null) {
  //         WebblenUser result = WebblenUser.fromMap(snapshot.data);
  //         results.add(result);
  //       }
  //     });
  //   }
  //   return results;
  // }

  Future<List<String?>> queryTags(String searchTerm) async {
    Algolia algolia = await initializeAlgolia();
    List<String?> results = [];
    if (searchTerm.isNotEmpty) {
      AlgoliaQuery query = algolia.instance.index('tags').query(searchTerm);
      AlgoliaQuerySnapshot snapshot = await query.getObjects();
      snapshot.hits.forEach((snapshot) {
        String? res = snapshot.data['tag'];
        if (res != null) {
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

  Future<List?> getRecentSearchTerms({required String uid}) async {
    List? recentSearchTerms = [];
    DocumentSnapshot snapshot = await userDocRef.doc(uid).get();
    if (snapshot.exists) {
      if (snapshot.data()!['recentSearchTerms'] != null) {
        recentSearchTerms = snapshot.data()!['recentSearchTerms'].toList(growable: true);
      }
    }
    return recentSearchTerms;
  }

  storeSearchTerm({required String? uid, required String? searchTerm}) async {
    List? recentSearchTerms = [];
    DocumentSnapshot snapshot = await userDocRef.doc(uid).get();
    if (snapshot.exists) {
      if (snapshot.data()!['recentSearchTerms'] != null) {
        recentSearchTerms = snapshot.data()!['recentSearchTerms'].toList(growable: true);
        if (!recentSearchTerms!.contains(searchTerm)) {
          recentSearchTerms.insert(0, searchTerm);
        }

        if (recentSearchTerms.length > 5) {
          recentSearchTerms.removeLast();
        }
      } else {
        recentSearchTerms.add(searchTerm);
      }
      userDocRef.doc(uid).update({'recentSearchTerms': recentSearchTerms});
    }
  }
}
