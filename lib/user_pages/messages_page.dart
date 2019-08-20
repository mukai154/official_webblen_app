import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_chat/chat_preview_row.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


class MessagesPage extends StatefulWidget {

  final WebblenUser currentUser;
  MessagesPage({this.currentUser});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {

  bool showLoadingDialog;
  List<WebblenChat> chats = [];
  int messageCount;
  bool isLoading = true;


  Future<void> loadUserChats() async {
    chats = [];
    QuerySnapshot chatQuery = await Firestore.instance.collection('chats').where('users', arrayContains: widget.currentUser.uid).getDocuments();
    if (chatQuery.documents != null && chatQuery.documents.length > 0){
      chatQuery.documents.forEach((chatDoc){
        WebblenChat chat = WebblenChat.fromMap(chatDoc.data);
        chats.add(chat);
      });
      chats.sort((chatA, chatB) => chatA.lastMessageTimeStamp.compareTo(chatB.lastMessageTimeStamp));
      isLoading = false;
      setState(() {});
    } else {
      isLoading = false;
      setState(() {});
    }
  }


  void transitionToUserDetails(WebblenUser webblenUser){
    PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: webblenUser).transitionToUserDetailsPage();
  }
  
  void didClickChat(WebblenChat c, int chatIndex, String username){
    List seenBy = c.seenBy.toList(growable: true);
    seenBy.add(widget.currentUser.uid);
    chats[chatIndex].seenBy = seenBy;
    setState(() {});
    PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        chatDocKey: c.chatDocKey,
        peerUsername: username
    ).transitionToChatPage();
  }


  @override
  void initState()  {
    super.initState();
    loadUserChats();
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
        child: isLoading
          ? LoadingScreen(context: context, loadingDescription: 'loading messages...',)
          : LiquidPullToRefresh(
          onRefresh: loadUserChats,
          child: chats.isEmpty
            ? ListView(
                  children: <Widget>[
                    SizedBox(height: 64.0),
                    Fonts().textW500('No Messages Found', 14.0, Colors.black45, TextAlign.center),
                    SizedBox(height: 8.0),
                    Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center)
                  ],
                )
            :  ListView.builder(
                shrinkWrap: true,
                itemCount: chats.length,
                itemBuilder: (context, index){
                  WebblenChat c = chats[index];
                  String username = c.usernames.firstWhere((username) => username != widget.currentUser.username);
                  return ChatRowPreview(
                    chattingWith: username,
                    lastMessageSentBy: c.lastMessageSentBy == widget.currentUser.username ? 'You' : c.lastMessageSentBy,
                    dateSent: c.lastMessageTimeStamp,
                    lastMessageSent: c.lastMessagePreview,
                    transitionToChat: () => didClickChat(chats[index], index, username),
                    lastMessageType: c.lastMessageType,
                    seenByUser: c.seenBy.contains(widget.currentUser.uid) ? true : false,
                  );
                },
              ),
        )
      ),
    );
  }
}