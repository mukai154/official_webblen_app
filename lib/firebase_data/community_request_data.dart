import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/community_request.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';

class CommunityRequestDataService {

  final CollectionReference comRequestRef = Firestore.instance.collection("community_requests");


  Future<CommunityRequest> getRequest(String reqID) async {
    CommunityRequest req;
    DocumentSnapshot comDoc = await comRequestRef.document(reqID).get();
    if (comDoc.exists){
      req = CommunityRequest.fromMap(comDoc.data);
    }
    return req;
  }

  Future<List<CommunityRequest>> getComRequests(String areaName) async {
    List<CommunityRequest> requests = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getCommunityRequests');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> reqMap =  Map<String, dynamic>.from(resultMap);
        CommunityRequest req = CommunityRequest.fromMap(reqMap);
        requests.add(req);
      });
    }
    return requests;
  }

  Future<String> updateVoting(String reqID, List upVotes, List downVotes) async {
    String error = '';
    await comRequestRef.document(reqID).updateData({
      'upVotes': upVotes,
      'downVotes': downVotes
    }).whenComplete((){
    }).catchError((e){
      error = e.details;
    });
    return error;
  }

  Future<String> postRequest(CommunityRequest req) async {
    String error = '';
    String reqID = Random().nextInt(99999999).toString();
    req.requestID = reqID;
    await comRequestRef.document(reqID).setData(req.toMap()).whenComplete((){
    }).catchError((e){
      error = e.details;
    });
    return error;
  }


}