import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:webblen/widgets_data_streams/stream_user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FriendsPage extends StatefulWidget {

  final String uid;
  FriendsPage({this.uid});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {

  bool showLoadingDialog;
  StreamSubscription userStream;
  WebblenUser currentUser;
  bool loadingFriends = true;
  bool loadingRequests = true;
  List<WebblenUser> friendList = [];


  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    StreamUserData.getUserStream(widget.uid, getUser).then((StreamSubscription<DocumentSnapshot> s){
      userStream = s;
    });
  }

  getUser(WebblenUser user){
    currentUser = user;
    if (currentUser != null){
      List friendIDs = currentUser.friends;
      if (friendIDs.isNotEmpty){
        getFriends(friendIDs);
      } else {
        loadingFriends = false;
        setState(() {});
      }
    }
  }

  getFriends(List friendIDs) async {
    friendIDs.forEach((friendID){
      UserDataService().getUserByID(friendID).then((user){
        if (user != null){
          friendList.add(user);
          if (friendIDs.last == friendID){
            friendList.sort((userA, userB) => userA.username.compareTo(userB.username));
            loadingFriends = false;
            setState(() {});
          }
        }
      });
    });
  }

  Widget buildFriendsView(){
    return loadingFriends
        ? LoadingScreen(context: context, loadingDescription: 'Loading...')
        : Container(
      height: MediaQuery.of(context).size.height * 0.88,
      child: friendList.length == 0
          ? buildEmptyListView("You Currently Have No Friends. Go Out to Events and Makes Some!", "desert")
          : ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              UserRow(
                  user: friendList[index],
                  transitionToUserDetails: () => PageTransitionService(context: context, currentUser: currentUser, webblenUser: friendList[index]).transitionToUserDetailsPage(),
                  sendUserFriendRequest: null,
                  isFriendsWithUser: true
              ),
          itemCount: friendList.length ,
      ),
    );
  }


  Widget buildEmptyListView(String emptyCaption, String pictureName){
    return Container(
      margin: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      color: Color(0xFFF9F9F9),
      child: new Column(
        children: <Widget>[
          SizedBox(height: 180.0),
          Fonts().textW500(emptyCaption, MediaQuery.of(context).size.width * 0.045, FlatColors.lightAmericanGray, TextAlign.center),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final appBar = AppBar (
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Color(0xFFF9F9F9),
      title: Text('Friends', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: FlatColors.blackPearl)),
      leading: BackButton(color: FlatColors.londonSquare),
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.search, size: 20.0, color: Colors.black45),
          onPressed: () => PageTransitionService(context: context, usersList: friendList, currentUser: currentUser, viewingMembersOrAttendees: false).transitionToUserSearchPage(),
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
          child:  buildFriendsView(),
        ),
    );
  }
}