import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';

class UserSearchPage extends StatefulWidget {

  final List userIDs;
  final WebblenUser currentUser;
  final bool viewingMembersOrAttendees;
  UserSearchPage({this.currentUser, this.userIDs, this.viewingMembersOrAttendees});

  @override
  _UserSearchPageState createState() => new _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {

  List<WebblenUser> searchResults = [];
  List<WebblenUser> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    UserDataService().getUsersFromList(widget.userIDs).then((result){
      users = result;
      users.sort((userA, userB) => userA.username.compareTo(userB.username));
      searchResults = users;
      isLoading = false;
      setState(() {});
    });
  }

  void sendFriendRequest(WebblenUser peerUser) async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().checkFriendStatus(widget.currentUser.uid, peerUser.uid).then((friendStatus){
      if (friendStatus == "pending"){
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Request Pending", "You already have a pending friend request");
      } else {
        WebblenNotificationDataService().sendFriendRequest(widget.currentUser.uid, peerUser.uid,  widget.currentUser.username).then((error){
          Navigator.of(context).pop();
          if (error.isEmpty){
            ShowAlertDialogService().showSuccessDialog(context, "Friend Request Sent!",  "@" + peerUser.username + " Will Need to Confirm Your Request");
          } else {
            ShowAlertDialogService().showFailureDialog(context, "Request Failed", error);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void initiateSearch(value) {
      if (value.length == 0) {
        setState(() {
          searchResults = users.toSet().toList();
        });
      } else {
        searchResults = users.where((user) => user.username.contains(value.toLowerCase())).toSet().toList();
        setState(() {});
      }
    }

    void transitionToUserDetails(WebblenUser webblenUser){
      Navigator.of(context).pop();
      PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: webblenUser).transitionToUserDetailsPage();
    }

    return  Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title:  Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
              onChanged: (val) {
                initiateSearch(val);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8.0),
                hintText: 'Search by name',
                border: InputBorder.none,
              )
          ),
        ),
        backgroundColor: Color(0xFFF9F9F9),
        brightness: Brightness.light,
        leading: BackButton(color: Colors.black45),
      ),
      body: isLoading
          ? LoadingScreen(context: context, loadingDescription: 'Searching Community...')
          : ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (BuildContext context, int i) {
            bool isFriendsWithUser = false;
            if (searchResults[i].friends != null && searchResults[i].friends.contains(widget.currentUser.uid)){
              isFriendsWithUser = true;
            }
            return Padding(
              padding: new EdgeInsets.symmetric(vertical: 8.0),
              child: new UserRow(
                  user: searchResults[i],
                  transitionToUserDetails: () => transitionToUserDetails(searchResults[i]),
                  sendUserFriendRequest: () => sendFriendRequest(searchResults[i]),
                  isFriendsWithUser: isFriendsWithUser),
            );
          }
      ),
    );
  }
}