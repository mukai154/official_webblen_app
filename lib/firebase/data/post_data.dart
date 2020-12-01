import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/location/location_service.dart';

class PostDataService {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");
  final Reference storageReference = FirebaseStorage.instance.ref();

  //CREATE
  Future<WebblenPost> uploadPost(WebblenPost post, String zipPostalCode, File postImgFile) async {
    List nearbyZipcodes = [];
    String newPostID = post.id == null ? randomAlphaNumeric(12) : post.id;
    post.id = newPostID;
    post.webAppLink = 'https://app.webblen.io/#/post?id=${post.id}';
    if (postImgFile != null) {
      String postFileName = "${post.id}.jpg";
      String imgURL = await uploadPostImage(postImgFile, postFileName);
      post.imageURL = imgURL;
    }
    if (zipPostalCode != null) {
      List listOfAreaCodes = await LocationService().findNearestZipcodes(zipPostalCode);
      if (listOfAreaCodes != null) {
        nearbyZipcodes = listOfAreaCodes;
      } else {
        nearbyZipcodes.add(zipPostalCode);
      }
      post.nearbyZipcodes = nearbyZipcodes;
    }
    await postsRef.doc(newPostID).set(post.toMap());

    return post;
  }

  Future<String> uploadPostImage(File postImage, String fileName) async {
    Reference ref = storageReference.child("posts").child(fileName);
    UploadTask uploadTask = ref.putFile(postImage);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> createPostFromEvent(WebblenEvent event, bool didEditEvent, List followers) async {
    String error;
    String postID = randomAlphaNumeric(12);
    WebblenPost post = WebblenPost(
      id: postID,
      parentID: event.id,
      authorID: event.authorID,
      postType: "event",
      imageURL: event.imageURL,
      body: didEditEvent
          ? event.isDigitalEvent
              ? " edited an upcoming stream: ${event.title}"
              : " edited an upcoming event: ${event.title}"
          : event.isDigitalEvent
              ? " scheduled an upcoming stream: ${event.title}"
              : " scheduled an upcoming event: ${event.title}",
      nearbyZipcodes: event.nearbyZipcodes,
      commentCount: 0,
      postDateTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      reported: false,
      savedBy: [],
      sharedComs: [],
      tags: event.tags,
      paidOut: event.paidOut,
      participantIDs: [],
      followers: followers,
    );
    postsRef.doc(post.id).set(post.toMap());
    return error;
  }

  //READ
  Future<List<WebblenPost>> getPosts({String cityFilter, String stateFilter, String categoryFilter, String typeFilter}) async {
    List<WebblenPost> posts = [];
    QuerySnapshot querySnapshot = await postsRef.get();
    querySnapshot.docs.forEach((snapshot) {
      WebblenPost post = WebblenPost.fromMap(snapshot.data());
      posts.add(post);
    });
    posts.sort((postA, postB) => postA.postDateTimeInMilliseconds.compareTo(postB.postDateTimeInMilliseconds));
    return posts;
  }

  Future<WebblenPost> getPost(String postID) async {
    WebblenPost post;
    await postsRef.doc(postID).get().then((res) {
      if (res.exists) {
        post = WebblenPost.fromMap(res.data());
      }
    }).catchError((e) {});
    return post;
  }

  //UPDATE
  Future updatePost(WebblenPost data, String id) async {
    await postsRef.doc(id).update(data.toMap());
    return;
  }

  Future<Null> removeUserFromFollowingPosts(String currentUID, String unfollowUID) async {
    QuerySnapshot query = await postsRef.where("authorID", isEqualTo: unfollowUID).where("followers", arrayContains: currentUID).get();
    query.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data();
      List followers = data['followers'].toList(growable: true);
      followers.remove(currentUID);
      postsRef.doc(doc.id).update({"followers": followers});
    });
  }

  //***DELETE
  Future<String> deletePost(String postID) async {
    String error = "";
    await postsRef.doc(postID).get().then((doc) async {
      if (doc.exists) {
        await postsRef.doc(postID).delete();
      }
    });
    return error;
  }
}
