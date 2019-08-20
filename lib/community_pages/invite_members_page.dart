import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';
import 'package:webblen/widgets_common/common_progress.dart';


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
  List<WebblenUser> searchResults = [];
  List<WebblenUser> friends = [];
  List invitedUsers = [];

  void validateAndSubmit(){
    if (invitedUsers.isEmpty){
      AlertFlushbar(headerText: "Error", bodyText: "You must select at least 1 person to invite").showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      invitedUsers.forEach((user) async {
        await WebblenNotificationDataService().checkIfComInviteExists(widget.community.areaName, widget.community.name, user).then((inviteExists) async {
          if (!inviteExists){
            await WebblenNotificationDataService().sendCommunityInviteNotif(
                widget.currentUser.uid,
                widget.community.areaName,
                widget.community.name,
                user,
                '@${widget.currentUser.username} invited you to join ${widget.community.name} in ${widget.community.areaName}'
            );
          }
        });
      });
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
      UserDataService().getUsersFromList(widget.currentUser.friends).then((result){
        if (result != null && result.isNotEmpty){
          friends = result;
          friends.sort((userA, userB) => userA.username.compareTo(userB.username));
          isLoading = false;
          setState(() {});
        }
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
          child: isLoading
              ? LoadingScreen(context: context, loadingDescription: 'Loading Friends...')
              : ListView.builder(
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