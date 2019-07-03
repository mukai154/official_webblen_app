import 'package:flutter/material.dart';
import 'dart:async';
import 'package:webblen/firebase_services/user_data.dart';
//import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:webblen/firebase_services/auth.dart';
import 'services_show_alert.dart';

class UserOptionsService {

  Future<String> sendFriendRequest(BuildContext context, String uid, String currentUsername, String peerUid, String peerUsername, String requestStatus) async {
    String friendRequestStatus;
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    await UserDataService().currentUsername(uid).then((currentUsername){
      if (currentUsername != null){
        UserDataService().addFriend(uid, currentUsername, peerUid).then((requestStatus){
          Navigator.of(context).pop();
          if (requestStatus == "success"){
            ShowAlertDialogService().showSuccessDialog(context, "Friend Request Sent!",  peerUsername + " Will Need to Confirm Your Request");
            friendRequestStatus = "pending";
          } else {
            ShowAlertDialogService().showFailureDialog(context, "Request Failed", requestStatus);
          }
        });
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Request Failed", "We're Not Too Sure What Happened... Please Try Again Later");
      }
    });
    return friendRequestStatus;
  }

  Future<String> messageUser(BuildContext context, String uid, String currentUsername, String peerUid, String peerUsername, String requestStatus) async {
    String friendRequestStatus;
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    await UserDataService().currentUsername(uid).then((currentUsername){
      if (currentUsername != null){
        UserDataService().addFriend(uid, currentUsername, peerUid).then((requestStatus){
          Navigator.of(context).pop();
          if (requestStatus == "success"){
            ShowAlertDialogService().showSuccessDialog(context, "Friend Request Sent!",  peerUsername + " Will Need to Confirm Your Request");
            friendRequestStatus = "pending";
          } else {
            ShowAlertDialogService().showFailureDialog(context, "Request Failed", requestStatus);
          }
        });
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Request Failed", "We're Not Too Sure What Happened... Please Try Again Later");
      }
    });
    return friendRequestStatus;
  }

  void signUserOut(BuildContext context) async {
    await FacebookLogin().logOut();
    BaseAuth().signOut().then((uid){
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

}