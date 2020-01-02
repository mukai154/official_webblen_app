import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:webblen/firebase_data/chat_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets_chat/chat_row.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';

class ChatPage extends StatefulWidget {
  final WebblenUser currentUser;
  final String chatKey;

  ChatPage({this.currentUser, this.chatKey});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<WebblenUser> chatUsers = [];
  File imageFile;
  String imageUrl;
  bool isLoading = true;
  WebblenChat chat;
  List<DocumentSnapshot> messages;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  void sendImage(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      imageFile = null;
    });
    imageFile = getImageFromCamera
        ? await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromCamera()
        : await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromLibrary();
    if (imageFile != null) {
      setState(() {});
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child('message_pics').child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, "image");
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      AlertFlushbar(headerText: "Image Error", bodyText: "This File Is Not an Image").showAlertFlushbar(context);
    });
  }

  void onSendMessage(String content, String type) {
    int messageSentTime = DateTime.now().millisecondsSinceEpoch;
    List seenByList = [widget.currentUser.uid];

    if (content.trim() != '') {
      textEditingController.clear();

      var messageReference = Firestore.instance.collection('chats').document(chat.chatDocKey).collection('messages').document(messageSentTime.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          messageReference,
          {
            'username': widget.currentUser.username,
            'timestamp': messageSentTime,
            'messageContent': content,
            'messageType': type,
            'uid': widget.currentUser.uid
          },
        );
      });
      ChatDataService().updateLastMessageSent(widget.chatKey, widget.currentUser.username, messageSentTime, type, seenByList, content);
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      AlertFlushbar(headerText: "Message Error", bodyText: "Nothing to Send").showAlertFlushbar(context);
    }
  }

  Widget buildMessageList() {
    return Flexible(
      child: StreamBuilder(
        stream:
            Firestore.instance.collection('chats').document(widget.chatKey).collection('messages').orderBy('timestamp', descending: true).limit(20).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black38)));
          } else {
            messages = snapshot.data.documents;
            if (messages.length > 0) messages.removeLast();
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                Widget messageWidget;
                WebblenChatMessage chatMessage = WebblenChatMessage.fromMap(messages[index].data);
                if (chatMessage.uid == widget.currentUser.uid) {
                  messageWidget = BuildSentMessage(currentUser: widget.currentUser, chatMessage: chatMessage, tapAction: null, longPressAction: null);
                } else {
                  messageWidget = BuildReceivedMessage(currentUser: widget.currentUser, chatMessage: chatMessage, tapAction: null, longPressAction: null);
                }
                return messageWidget;
              },
              itemCount: messages.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildInputField() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () => ShowAlertDialogService().showImageSelectDialog(context, () => sendImage(true), () => sendImage(false)),
                color: FlatColors.webblenRed,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: FlatColors.blackPearl, fontSize: 18.0, fontWeight: FontWeight.w500),
                controller: textEditingController,
                maxLines: null,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: FlatColors.londonSquare),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, "text"),
                color: FlatColors.webblenRed,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(border: new Border(top: new BorderSide(color: FlatColors.clouds, width: 1)), color: Colors.white),
    );
  }

  @override
  void initState() {
    super.initState();
    ChatDataService().findChatByKey(widget.chatKey).then((res) {
      chat = res;
      chat.users.forEach((uid) {
        UserDataService().getUserByID(uid).then((res) {
          if (res != null) {
            chatUsers.add(res);
          }
          if (chat.users.last == uid) {
            isLoading = false;
            if (this.mounted) {
              setState(() {});
            }
          }
        });
      });
    });
    //focusNode.addListener(onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar('Chat', context),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  buildMessageList(),
                  buildInputField(),
                ],
              ),
              // Loading
              //buildLoading()
            ],
          ),
        ),
        //onWillPop: onBackPress,
      ),
    );
  }
}
