import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_chat/chat_preview_row.dart';
import 'package:webblen/models/webblen_chat_message.dart';


class MessagesPage extends StatefulWidget {

  final WebblenUser currentUser;
  MessagesPage({this.currentUser});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {

  bool showLoadingDialog;
  List messages;
  int messageCount;

  Widget buildMessagesView(){
    UserDataService().updateMessageNotifications(widget.currentUser.uid);
    return Container(
      color: Colors.white,
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('chats')
            .where('users', arrayContains: widget.currentUser.uid)
            .orderBy('lastMessageTimeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (!chatSnapshot.hasData) return _buildLoadingScreen();
          return chatSnapshot.data.documents.isEmpty
              ? buildEmptyListView("You Have No Messages", "paper_plane")
              : ListView(
                children: chatSnapshot.data.documents.map((DocumentSnapshot chatDoc){
                  if (chatDoc['isActive'] == false && chatSnapshot.data.documents.length <= 1){
                    return buildEmptyListView("You Have No Messages", "paper_plane");
                  } else if (chatDoc['isActive'] == false){
                    return Container();
                  }
                  //chatSnapshot.data.documents.sort((chatDocA, chatDocB) => chatDocB.data['lastMessageTimeStamp'].compareTo(chatDocA.data['lastMessageTimeStamp']));
                  WebblenChat chatData = WebblenChat.fromMap(chatDoc.data);
                  String username = chatData.usernames.firstWhere((username) => username != widget.currentUser.username);
                  String peerUid = chatData.users.firstWhere((user) => user != widget.currentUser.uid);
                  String peerProfilePic = chatData.userProfiles[peerUid];
                  if (chatData.lastMessageSentBy == widget.currentUser.username){
                    chatData.lastMessageSentBy = "you: ";
                  } else {
                    chatData.lastMessageSentBy = "";
                  }
                  return ChatRowPreview(
                    chattingWith: username,
                    lastMessageSentBy: chatData.lastMessageSentBy,
                    dateSent: chatData.lastMessageTimeStamp,
                    lastMessageSent: chatData.lastMessagePreview,
                    transitionToChat: () => PageTransitionService(
                        context: context,
                        currentUser: widget.currentUser,
                        chatDocKey: chatDoc.documentID,
                        peerUsername: username,
                        peerProfilePic: peerProfilePic).transitionToChatPage(),
                    lastMessageType: chatData.lastMessageType,
                    seenByUser: chatData.seenBy.contains(widget.currentUser.uid) ? true : false,
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Widget buildEmptyListView(String emptyCaption, String pictureName){
    return Container(
      margin: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          SizedBox(height: 160.0),
          new Container(
            height: 85.0,
            width: 85.0,
            child: new Image.asset("assets/images/$pictureName.png", fit: BoxFit.scaleDown),
          ),
          SizedBox(height: 16.0),
          Fonts().textW500(emptyCaption, 16.0, FlatColors.blueGray, TextAlign.center),
        ],
      ),
    );
  }


  Widget _buildLoadingScreen()  {
    return new Container(
      width: MediaQuery.of(context).size.width,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 185.0),
          CustomCircleProgress(50.0, 50.0, 40.0, 40.0, FlatColors.londonSquare),
        ],
      ),
    );
  }


  void transitionToUserDetails(WebblenUser webblenUser){
    PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: webblenUser).transitionToUserDetailsPage();
  }


  @override
  void initState()  {
    super.initState();
//    UserDataService().findUserByID(widget.currentUser.uid).then((user){
//      setState(() {
//        messageCount = user.messageNotificationCount;
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {

    final appBar = AppBar (
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700('Messages', 18.0, Colors.black, TextAlign.center),
      leading: BackButton(color: Colors.black),
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        child: buildMessagesView(),
      ),
    );
  }
}