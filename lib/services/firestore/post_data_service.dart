import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';

class PostDataService {
  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  int dateTimeInMilliseconds1MonthAgo = DateTime.now().millisecondsSinceEpoch - 2628000000;
  SnackbarService _snackbarService = locator<SnackbarService>();

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadPosts({
    @required String areaCode,
    @required int resultsLimit,
    @required String tagFilter,
    @required String sortBy,
  }) async {
    print(tagFilter);
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsLimit);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsLimit);
    }
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
      if (tagFilter.isNotEmpty) {
        docs.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docB.data()['postDateTimeInMilliseconds'].compareTo(docA.data()['postDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalPosts(
      {@required DocumentSnapshot lastDocSnap,
      @required String areaCode,
      @required int resultsLimit,
      @required String tagFilter,
      @required String sortBy}) async {
    print(tagFilter);
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter.isNotEmpty) {
        docs.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docB.data()['postDateTimeInMilliseconds'].compareTo(docA.data()['postDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      }
    }
    return docs;
  }
}
