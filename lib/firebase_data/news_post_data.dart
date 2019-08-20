import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/models/community_news.dart';
import 'package:cloud_functions/cloud_functions.dart';

class NewsPostDataService {

  final CollectionReference newsPostRef = Firestore.instance.collection("community_news");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<bool> checkIfPostExists(String eventType, String eventID) async {
    bool postExists = false;
    await newsPostRef.document(eventID).get().then((result){
      if (result.exists){
        postExists = true;
      }
    });
    return postExists;
  }
  Future<CommunityNewsPost> getPost(String postID) async {
    CommunityNewsPost newPost;
    DocumentSnapshot comDoc = await newsPostRef.document(postID).get();
    if (comDoc.exists){
      newPost = CommunityNewsPost.fromMap(comDoc.data);
    }
    return newPost;
  }

  Future<List<CommunityNewsPost>> getCommunityNewsPosts(String areaName, String comName) async {
    List<CommunityNewsPost> posts = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getCommunityNewsPosts');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': comName});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> postMap =  Map<String, dynamic>.from(resultMap);
        CommunityNewsPost post = CommunityNewsPost.fromMap(postMap);
        posts.add(post);
      });
    }
    return posts;
  }

  Future<List<CommunityNewsPost>> getUserNewsPostFeed(Map<dynamic, dynamic> userComs) async {
    List<CommunityNewsPost> posts = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserNewsPostFeed');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'userComs': userComs});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> postMap =  Map<String, dynamic>.from(resultMap);
        CommunityNewsPost post = CommunityNewsPost.fromMap(postMap);
        posts.add(post);
      });
    }
    return posts;
  }






}