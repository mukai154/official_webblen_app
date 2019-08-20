import 'package:flutter/material.dart';
import 'dart:async';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:webblen/firebase_data/auth.dart';
import 'services_show_alert.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserOptionsService {

  Future<String> sendFriendRequest(BuildContext context, String uid, String currentUsername, String peerUid, String peerUsername, String requestStatus) async {
    String friendRequestStatus;
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    await UserDataService().getUsername(uid).then((currentUsername){
      if (currentUsername != null){
        WebblenNotificationDataService().sendFriendRequest(uid, peerUid, peerUsername).then((requestStatus){
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
    await UserDataService().getUsername(uid).then((currentUsername){
      if (currentUsername != null){
        WebblenNotificationDataService().sendFriendRequest(uid, peerUid, peerUsername).then((requestStatus){
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
    await GoogleSignIn().signOut();
    BaseAuth().signOut().then((uid){
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

}