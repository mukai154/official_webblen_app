import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/chat_data.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_chat/chat_preview_row.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/widgets_common/common_progress.dart';

class ChatsIndexPage extends StatefulWidget {
  final WebblenUser currentUser;
  ChatsIndexPage({this.currentUser});

  @override
  _ChatsIndexPageState createState() => _ChatsIndexPageState();
}

class _ChatsIndexPageState extends State<ChatsIndexPage> {
  bool isLoading = true;
  List<WebblenChat> chats = [];

  Future<void> loadUserChats() async {
    chats = [];
    QuerySnapshot chatQuery = await Firestore.instance.collection('chats').where('users', arrayContains: widget.currentUser.uid).getDocuments();
    if (chatQuery.documents != null && chatQuery.documents.length > 0) {
      chatQuery.documents.forEach((chatDoc) {
        if (chatDoc.data['isActive']) {
          WebblenChat chat = WebblenChat.fromMap(chatDoc.data);
          chats.add(chat);
        }
      });
      chats.sort((chatA, chatB) => chatA.lastMessageTimeStamp.compareTo(chatB.lastMessageTimeStamp));
      isLoading = false;
      setState(() {});
    } else {
      isLoading = false;
      setState(() {});
    }
  }

  void didClickChat(WebblenChat c, int chatIndex) {
    List seenBy = c.seenBy.toList(growable: true);
    seenBy.add(widget.currentUser.uid);
    chats[chatIndex].seenBy = seenBy;
    ChatDataService().updateSeenMessage(c.chatDocKey, widget.currentUser.uid);
    setState(() {});
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      chatKey: c.chatDocKey,
    ).transitionToChatPage();
  }

  @override
  void initState() {
    super.initState();
    loadUserChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
          "Messages",
          IconButton(
            icon: Icon(FontAwesomeIcons.edit, size: 16.0, color: Colors.black),
            onPressed: () => PageTransitionService(context: context, currentUser: widget.currentUser).transitionToChatInviteSharePage(),
          )),
      body: Container(
          child: isLoading
              ? LoadingScreen(
                  context: context,
                  loadingDescription: 'loading messages...',
                )
              : LiquidPullToRefresh(
                  color: FlatColors.webblenRed,
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
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            WebblenChat c = chats[index];
                            return ChatRowPreview(
                              chatName: c.chatName == null ? "@" + c.lastMessageSentBy : c.chatName,
                              lastMessageSentBy: c.lastMessageSentBy == widget.currentUser.username ? 'You' : c.lastMessageSentBy,
                              dateSent: c.lastMessageTimeStamp,
                              lastMessageSent: c.lastMessagePreview,
                              transitionToChat: () => didClickChat(chats[index], index),
                              lastMessageType: c.lastMessageType,
                              seenByUser: c.seenBy.contains(widget.currentUser.uid) ? true : false,
                              numberOfUsersInChat: c.users.length,
                            );
                          },
                        ),
                )),
    );
  }
}
