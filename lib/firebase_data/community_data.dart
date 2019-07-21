import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'dart:io';
import 'package:webblen/models/community_news.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/firebase_data/firebase_notification_services.dart';
import 'package:webblen/models/event.dart';

class CommunityDataService {

  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference locRef = Firestore.instance.collection("locations");
  final CollectionReference eventRef = Firestore.instance.collection("events");
  final CollectionReference usersRef = Firestore.instance.collection("users");
  final CollectionReference communityNewsDataRef = Firestore.instance.collection("community_news");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<String> createCommunity(Community community, String areaName, String uid) async {
    String error = "";
    Map<dynamic, dynamic> userComs;
    List userAreaComs;
    DocumentSnapshot userDoc = await usersRef.document(uid).get();
    userComs = userDoc.data['communities'];
    userAreaComs = userComs[areaName] != null ? userComs[areaName].toList(growable: true) : [];
    userAreaComs.add(community.name);
    userComs[areaName] = userAreaComs;
    await locRef.document(areaName).collection('communities').document(community.name).setData(community.toMap()).whenComplete((){
    }).catchError((e){
      error = e.details.toString();
    });
    await usersRef.document(uid).updateData({'communities': userComs}).whenComplete((){
    }).catchError((e){
      error = e.details;
    });
    return error;
  }

  Future<Community> getCommunity(String areaName, String comName) async {
    Community com;
    DocumentSnapshot docSnap = await locRef.document(areaName).collection('communities').document(comName).get();
    if (docSnap.exists){
      com = Community.fromMap(docSnap.data);
    }
    return com;
  }

  Future<bool> findIfCommunityExists(String areaName, String comName) async {
    bool communityNameExists = false;
    DocumentSnapshot docSnap = await locRef.document(areaName).collection('communities').document(comName).get();
    if (docSnap.exists){
      communityNameExists = true;
    }
    return communityNameExists;
  }

  Future<List<Community>> findAllMemberCommunities(String uid) async {
    List<Community> memberCommunities = [];
    DocumentSnapshot userDoc = await usersRef.document(uid).get();
    Map<dynamic, dynamic> communities = userDoc.data['communities'];
    for (var entry in communities.entries){
      List areaCommunities = entry.value;
      for (var comName in areaCommunities){
        await locRef.document(entry.key).collection('communities').document(comName).get().then((docSnap){
          if (docSnap.exists){
            Community community = Community.fromMap(docSnap.data);
            memberCommunities.add(community);
          }
        });
      }
    }
    return memberCommunities;
  }

  Future<List> updateFollowers(String uid, String areaName, String comName) async{
    Map<dynamic, dynamic> followingComs;
    List followers = [];
    List areaComsFollowing = [];
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    DocumentSnapshot userDoc = await usersRef.document(uid).get();
    followers = comDoc.data['followers'].toList(growable: true);
    followingComs = userDoc.data['followingCommunities'];
    areaComsFollowing = followingComs[areaName] != null ? followingComs[areaName].toList(growable: true) : [];
    if (followers.contains(uid)){
      followers.remove(uid);
      areaComsFollowing.remove(comName);
      if (areaComsFollowing.isEmpty){
        followingComs.remove(areaName);
      }
    } else {
      followers.add(uid);
      areaComsFollowing.add(comName);
    }
    followingComs[areaName] = areaComsFollowing;
    locRef.document(areaName).collection('communities').document(comName).updateData(({'followers': followers})).whenComplete((){
      usersRef.document(uid).updateData({"followingCommunities": followingComs}).whenComplete((){

      });
    }).catchError((e){
    });
    return followers;
  }

  Future<String> inviteUsers(List invitedUsers, String areaName, String comName, String senderUid, String senderName) async{
    String error = "";
    List invited = [];
    List newInvites = [];
    String notifData = comName + "." + areaName;
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    invited = comDoc.data['invited'].toList(growable: true);
    invitedUsers.forEach((uid){
      if (!invited.contains(uid)){
        invited.add(uid);
        newInvites.add(uid);
      }
    });
    await locRef.document(areaName).collection('communities').document(comName).updateData(({'invited': invited})).whenComplete((){
      newInvites.forEach((uid) async {
        await FirebaseNotificationsService().createInviteNotification(senderUid, notifData, uid, "@$senderName invited you to join $comName").whenComplete((){
        }).catchError((e){
          error = e.details;
        });
      });
    }).catchError((e){
      error = e.details;
    });
    return error;
  }

  Future<String> removeInvitedUser(String uid, String areaName, String comName) async{
    String error = "";
    List invited = [];
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    if (comDoc.exists){
      invited = comDoc.data['invited'].toList(growable: true);
      if (invited.contains(uid)){
        invited.remove(uid);
      }
      await locRef.document(areaName).collection('communities').document(comName).updateData(({'invited': invited})).whenComplete((){
      }).catchError((e){
        error = e.details;
      });
    }
    return error;
  }

  Future<String> updateMembers(String uid, String areaName, String comName) async {
    String error = "";
    bool disbandCom = false;
    Map<dynamic, dynamic> userComs;
    List memberIDs;
    int currentDateTime = DateTime.now().millisecondsSinceEpoch;
    int comActivityCount = 0;
    List invitedUsers = [];
    List userAreaComs = [];
    String comStatus = "pending";
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    DocumentSnapshot userDoc = await usersRef.document(uid).get();
    if (comDoc.exists){
      comActivityCount = comDoc.data['activityCount'];
      userComs = userDoc.data['communities'];
      memberIDs = comDoc.data['memberIDs'].toList(growable: true);
      invitedUsers = comDoc.data['invited'].toList(growable: true);
      userAreaComs = userComs[areaName] != null ? userComs[areaName].toList(growable: true) : [];
      if (userAreaComs.contains(comName)){
        comActivityCount -= 1;
        userAreaComs.remove(comName);
        memberIDs.remove(uid);
        if (userAreaComs.isEmpty){
          userComs.remove(areaName);
        }
        if (memberIDs.length < 3){
          disbandCom = true;
        }
      } else {
        comActivityCount += 1;
        invitedUsers.remove(uid);
        userAreaComs.add(comName);
        memberIDs.add(uid);
      }
      if (memberIDs.length >= 3){
        comStatus = "active";
      }
      userComs[areaName] = userAreaComs;
      if (disbandCom){
        await locRef.document(areaName).collection('communities').document(comName).delete();
        usersRef.document(uid).updateData({"communities": userComs}).whenComplete((){
        }).catchError((e){});
      } else {
        await locRef.document(areaName).collection('communities').document(comName).updateData(({'memberIDs': memberIDs, 'invited': invitedUsers, 'activityCount': comActivityCount, 'lastActivityTimeInMilliseconds': currentDateTime, 'status': comStatus})).whenComplete((){
          usersRef.document(uid).updateData({"communities": userComs}).whenComplete((){
          });
        }).catchError((e){
          error = e.details;
        });
      }
    } else {
      error = 'doesNotExist';
    }
    return error;
  }

  Future<List<CommunityNewsPost>> getPostsFromCommunity(String areaName, String communityName) async {
    List<CommunityNewsPost> posts = [];
    QuerySnapshot querySnapshot = await communityNewsDataRef
        .where("areaName", isEqualTo: areaName)
        .where("communityName", isEqualTo: communityName)
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((newsDoc){
        CommunityNewsPost newsPost = CommunityNewsPost.fromMap(newsDoc.data);
        posts.add(newsPost);
      });
    }
    return posts;
  }

  Future<List<Event>> getEventsFromCommunities(String areaName, String communityName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await eventRef
        .where("communityAreaName", isEqualTo: areaName)
        .where("communityName", isEqualTo: communityName)
        .where('recurrence', isEqualTo: 'none')
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((eventDoc){
        Event event = Event.fromMap(eventDoc.data);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Community>> searchForCommunityByName(String searchTerm, String areaName) async {
    List<Community> communities = [];
    String modifiedSearchTerm = searchTerm.contains("#") ? searchTerm : "#$searchTerm";
    DocumentSnapshot docSnap = await locRef.document(areaName).collection('communities').document(modifiedSearchTerm).get();
    if (docSnap.exists && docSnap.data['status'] == "active"){
      Community com = Community.fromMap(docSnap.data);
      communities.add(com);
    }
    return communities;
  }

  Future<List<Community>> searchForCommmunityByTag(String searchTerm, String areaName) async {
    List<Community> communities = [];
    QuerySnapshot querySnapshot = await locRef.document(areaName).collection('communities').where("subtags", arrayContains: searchTerm).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((docSnap){
        if (docSnap.data['status'] == "active"){
          Community com = Community.fromMap(docSnap.data);
          communities.add(com);
        }
      });
    }
    return communities;
  }

  Future<String> uploadNews(File newsImage, CommunityNewsPost communityNews) async {
    String error = "";
    final String postID = "${Random().nextInt(999999999)}";
    String fileName = "$postID.jpg";
    communityNews.postID = postID;
    if (newsImage != null){
      String downloadUrl = await uploadNewsImage(newsImage, fileName);
      communityNews.imageURL = downloadUrl;
    }
    await Firestore.instance.collection("community_news").document(postID).setData(communityNews.toMap()).whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> uploadNewsImage(File eventImage, String fileName) async {
    StorageReference ref = storageReference.child("community_news").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  Future<String> updateCommunityEventActivity(List tags, String areaName, String comName) async {
    String error = "";
    List comTags = [];
    List newTagList;
    int activityCount = 0;
    int eventCount  = 0;
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    comTags = comDoc.data['subtags'] == null ? [] : comDoc.data['subtags'];
    activityCount = comDoc.data['activityCount'] == null ? 0 : comDoc.data['activityCount'];
    eventCount = comDoc.data['eventCount'] == null ? 0 : comDoc.data['eventCount'];
    activityCount += 1;
    eventCount += 1;
    newTagList = List.from(comTags)..addAll(tags);
    List uniqueTags = newTagList.toSet().toList();
    await locRef.document(areaName).collection("communities").document(comName).updateData({"subtags": uniqueTags, "activityCount": activityCount, "eventCount": eventCount}).whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<CommunityNewsPost> getPost(String postID) async {
    CommunityNewsPost newPost;
    DocumentSnapshot comDoc = await communityNewsDataRef.document(postID).get();
    if (comDoc.exists){
      newPost = CommunityNewsPost.fromMap(comDoc.data);
    }
    return newPost;
  }

  Future<String> deletePost(String postID) async {
    String error = "";
    await FirebaseNotificationsService().deleteNotificationsByPost(postID);
    await communityNewsDataRef.document(postID).delete();
    await storageReference.child("community_news").child('$postID.jpg').delete();
    return error;
  }

//  Future<Null> updateCommunityDataFields() async {
//    QuerySnapshot locQ = await locRef.getDocuments();
//    locQ.documents.forEach((areaDoc) async {
//      QuerySnapshot comQ = await locRef.document(areaDoc.documentID).collection('communities').getDocuments();
//      comQ.documents.forEach((comDoc) async {
//        List memberIDs = [];
//        Map<dynamic, dynamic> members = comDoc.data['members'] == null ? {} : comDoc.data['members'];
//        members.forEach((key, val){
//          memberIDs.add(key);
//        });
//        await locRef.document(areaDoc.documentID).collection('communities').document(comDoc.documentID).updateData({'memberIDs': memberIDs});
//      });
//    });
//  }

//    Future<Null> convertComData() async {
//    locRef.getDocuments().then((docs){
//      docs.documents.forEach((doc) async {
//        String geoH = doc.data['location']['geohash'];
//        double lat = doc.data['location']['geopoint'].latitude;
//        double lon = doc.data['location']['geopoint'].longitude;
//        GeoPoint latLon = geo.point(latitude: lat, longitude: lon).geoPoint;
//        lRef.document(doc.documentID).setData({'d': {}, 'g': geoH, 'l': latLon});
//        QuerySnapshot comQuery = await locRef.document(doc.documentID).collection('communities').getDocuments();
//        comQuery.documents.forEach((comDoc) async{
//          lRef.document(doc.documentID).collection('communities').document(comDoc.documentID).setData(comDoc.data);
//        });
//
//      });
//    });
//  }

  Future<Null> updateCommunityDataFields() async {
    QuerySnapshot locQ = await locRef.getDocuments();
    locQ.documents.forEach((areaDoc) async {
      QuerySnapshot comQ = await locRef.document(areaDoc.documentID).collection('communities').getDocuments();
      comQ.documents.forEach((comDoc) async {
        await locRef.document(areaDoc.documentID).collection('communities').document(comDoc.documentID).updateData({'communityType': 'closed'});
      });
    });
  }

}