import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/widgets_user/user_row.dart';



class InviteMembersPage extends StatefulWidget {

  final WebblenUser currentUser;
  final Community community;
  InviteMembersPage({this.currentUser, this.community});

  @override
  State<StatefulWidget> createState() {
    return _InviteMembersPageState();
  }
}

class _InviteMembersPageState extends State<InviteMembersPage> {


  bool isLoading = true;

  //Event
  List<WebblenUser> searchResults = [];
  List<WebblenUser> friends = [];
  List invitedUsers = [];


  void validateAndSubmit(){
    if (invitedUsers.isEmpty){
      AlertFlushbar(headerText: "Error", bodyText: "You must select at least 1 person to invite").showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      CommunityDataService().inviteUsers(invitedUsers, widget.community.areaName, widget.community.name, widget.currentUser.uid, widget.currentUser.username).then((error){
        if (error.isEmpty){
          Navigator.of(context).pop();
          ShowAlertDialogService().showActionSuccessDialog(
              context,
              "Users Invited!",
              "Way to grow your community!",
                  (){
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
          );
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(context, 'Uh Oh', 'There was an issue... Please try again.');
        }
      });
      //Navigator.push(context, ScaleRoute(widget: ConfirmEventPage(newEvent: newEventPost, newEventImage: eventImage)));
    }
  }

  void initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        searchResults = friends;
      });
    } else {
      searchResults = friends.where((user) => user.username.contains(value.toLowerCase())).toList();
      setState(() {});
    }
  }



  @override
  void initState() {
    super.initState();
    if (widget.currentUser.friends != null || widget.currentUser.friends.isNotEmpty){
      widget.currentUser.friends.forEach((uid){
        UserDataService().getUserByID(uid).then((user){
          if (user != null){
            if (!widget.community.memberIDs.contains(user.uid)){
              friends.add(user);
            }
            if (widget.currentUser.friends.last == uid){
              friends.sort((userA, userB) => userA.username.compareTo(userB.username));
              isLoading = false;
              setState(() {});
            }
          }
        });
      });
    } else {
      isLoading = false;
      setState(() {});
    }

  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
          "Invite Users",
          GestureDetector(
            onTap: this.validateAndSubmit,
            child: Padding(
              padding: EdgeInsets.only(top: 18.0, right: 16.0),
              child: Fonts().textW500('Invite', 18.0, FlatColors.darkGray, TextAlign.center),
            )
          )
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index){
              String friendUid = friends[index].uid;
              return UserRowInvite(
                user: friends[index],
                onTap: (){
                  if (invitedUsers.contains(friendUid)){
                    invitedUsers.remove(friendUid);
                  } else {
                    invitedUsers.add(friendUid);
                  }
                  setState(() {});
                },
                didInvite: invitedUsers.contains(friends[index].uid),
              );
            },
          )
      )
    );
  }

}