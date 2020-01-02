import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'dart:io';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_data_streams/stream_comment_data.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/models/comment.dart';
import 'package:webblen/firebase_data/comment_data.dart';
import 'package:webblen/models/community_request.dart';

class CommunityRequestDetailsPage extends StatefulWidget {

  final CommunityRequest request;
  final WebblenUser currentUser;
  CommunityRequestDetailsPage({this.request, this.currentUser});

  @override
  _CommunityRequestDetailsPageState createState() => _CommunityRequestDetailsPageState();
}

class _CommunityRequestDetailsPageState extends State<CommunityRequestDetailsPage> {

  File commentImage;
  String commentImageUrl;

  bool isLoading;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();


  void sendImage(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      commentImage = null;
    });
    commentImage = getImageFromCamera
        ? await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromCamera()
        : await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromLibrary();
    if (commentImage != null){
      setState(() {});
    }
  }

  Future uploadFile() async {
    String fileName = widget.request.requestID + "-" + DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child('request_pics').child(fileName);
    StorageUploadTask uploadTask = reference.putFile(commentImage);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      commentImageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(commentImageUrl, "image", fileName);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      AlertFlushbar(headerText: "Image Error", bodyText: "This File Is Not an Image").showAlertFlushbar(context);
    });
  }

  void onSendMessage(String content, String type, String key) {

    int commentSentTime = DateTime.now().millisecondsSinceEpoch;
    String commentKey = key == null ? widget.request.requestID + "-" + DateTime.now().millisecondsSinceEpoch.toString() : key;

    if (content.trim() != '') {
      textEditingController.clear();

      Comment newComment = Comment(
          commentKey: commentKey,
          postDateInMilliseconds: commentSentTime,
          uid: widget.currentUser.uid,
          username: widget.currentUser.username,
          userImageURL: widget.currentUser.profile_pic,
          postID: widget.request.requestID,
          content: content,
          contentType: type,
          flagged: false
      );

      CommentDataService().createComment(newComment).then((error){
        if (error.isEmpty){
        } else {
          AlertFlushbar(headerText: "Message Error", bodyText: "Nothing to Send").showAlertFlushbar(context);
        }
      });
      FocusScope.of(context).unfocus();
    }
  }

  Widget requestContent(){
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: Fonts().textW700(widget.request.requestTitle, 24.0, FlatColors.darkGray, TextAlign.left),
          ),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Fonts().textW400(widget.request.requestExplanation, 18.0, FlatColors.lightAmericanGray, TextAlign.left),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }


  Widget buildInput() {
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
              child:  MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: TextField(
                    style: TextStyle(color: FlatColors.blackPearl, fontSize: 18.0, fontWeight: FontWeight.w500),
                    controller: textEditingController,
                    maxLines: null,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: FlatColors.londonSquare),
                    ),
                  ),
              ),

            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, "text", null),
                color: FlatColors.webblenRed,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: FlatColors.clouds, width: 1)),
          color: Colors.white
      ),
    );
  }

  Widget postView(){
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          requestContent()
        ],
      ),
    );
  }

  Widget buildCommmentsList() {
    return Flexible(
      child: StreamRequestCommentData(
        currentUser: widget.currentUser,
        requestID: widget.request.requestID,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: WebblenAppBar().actionAppBar(
            "Request Chat",
            Container()
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: postView(),
              ),
              Expanded(
                flex: 6,
                child: StreamRequestCommentData(
                  currentUser: widget.currentUser,
                  requestID: widget.request.requestID,
                  scrollController: listScrollController,
                ),
              ),
              Expanded(
                flex: 1,
                child: buildInput(),
              ), // Loading
            ],
          ),
        )
    );
  }
}

