import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase_data/comment_data.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/comment.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets/widgets_data_streams/stream_comment_data.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CommunityPostCommentsPage extends StatefulWidget {
  final CommunityNewsPost newsPost;
  final WebblenUser currentUser;

  CommunityPostCommentsPage({
    this.newsPost,
    this.currentUser,
  });

  @override
  _CommunityPostCommentsPageState createState() => _CommunityPostCommentsPageState();
}

class _CommunityPostCommentsPageState extends State<CommunityPostCommentsPage> {
  File commentImage;
  String commentImageUrl;
  YoutubePlayerController vidController;
  bool isYoutubeVideo = false;
  String youtubeVideoID;
  bool isLoading;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  void transitionToPostAuthorProfile() async {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().getUserByName(widget.newsPost.username).then((result) {
      if (result != null) {
        Navigator.of(context).pop();
        PageTransitionService(
          context: context,
          currentUser: widget.currentUser,
          webblenUser: result,
        ).transitionToUserPage();
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "That's Odd...",
          "There was an issue. Please try again later.",
        );
      }
    });
  }

  void sendImage(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      commentImage = null;
    });
    commentImage = getImageFromCamera
        ? await WebblenImagePicker(
            context: context,
            ratioX: 9.0,
            ratioY: 7.0,
          ).retrieveImageFromCamera()
        : await WebblenImagePicker(
            context: context,
            ratioX: 9.0,
            ratioY: 7.0,
          ).retrieveImageFromLibrary();
    if (commentImage != null) {
      setState(() {});
    }
  }

  Future uploadFile() async {
    String fileName = widget.newsPost.postID + "-" + DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child('comment_pics').child(fileName);
    StorageUploadTask uploadTask = reference.putFile(commentImage);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      commentImageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(
          commentImageUrl,
          "image",
          fileName,
        );
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      AlertFlushbar(
        headerText: "Image Error",
        bodyText: "This File Is Not an Image",
      ).showAlertFlushbar(context);
    });
  }

  void onSendMessage(String content, String type, String key) {
    int commentSentTime = DateTime.now().millisecondsSinceEpoch;
    String commentKey = key == null ? widget.newsPost.postID + "-" + DateTime.now().millisecondsSinceEpoch.toString() : key;

    if (content.trim() != '') {
      textEditingController.clear();

      Comment newComment = Comment(
        commentKey: commentKey,
        postDateInMilliseconds: commentSentTime,
        uid: widget.currentUser.uid,
        username: widget.currentUser.username,
        userImageURL: widget.currentUser.profile_pic,
        postID: widget.newsPost.postID,
        content: content,
        contentType: type,
        flagged: false,
      );

      CommentDataService().createComment(newComment).then((error) {
        if (error.isEmpty) {
        } else {
          AlertFlushbar(
            headerText: "Message Error",
            bodyText: "Nothing to Send",
          ).showAlertFlushbar(context);
        }
      });
      FocusScope.of(context).unfocus();
    }
  }

  Widget postContent() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Fonts().textW700(
              widget.newsPost.title,
              24.0,
              FlatColors.darkGray,
              TextAlign.left,
            ),
          ),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Fonts().textW400(
              widget.newsPost.content,
              18.0,
              FlatColors.lightAmericanGray,
              TextAlign.left,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          widget.newsPost.newsURL != null || widget.newsPost.newsURL.isNotEmpty
              ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(
                    context,
                    widget.newsPost.newsURL,
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW400(
                      widget.newsPost.newsURL,
                      18.0,
                      FlatColors.electronBlue,
                      TextAlign.left,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget postAuthor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            widget.newsPost.userImageURL == null
                ? Container()
                : GestureDetector(
                    onTap: transitionToPostAuthorProfile,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12.0,
                        top: 12.0,
                        right: 4.0,
                      ),
                      child: UserProfilePicFromUsername(
                        username: widget.newsPost.username,
                        size: 50.0,
                      ),
                    ),
                  ),
            Padding(
              padding: EdgeInsets.only(
                left: 4.0,
                top: 12.0,
                right: 4.0,
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: GestureDetector(
                  onTap: transitionToPostAuthorProfile,
                  child: Fonts().textW700(
                    "@" + widget.newsPost.username,
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.start,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: 1.0,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.image,
                ),
                onPressed: () => ShowAlertDialogService().showImageSelectDialog(
                  context,
                  () => sendImage(true),
                  () => sendImage(false),
                ),
                color: FlatColors.webblenRed,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: TextField(
                  style: TextStyle(color: FlatColors.blackPearl, fontSize: 18.0, fontWeight: FontWeight.w500),
                  controller: textEditingController,
                  maxLines: null,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: FlatColors.londonSquare,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                ),
                onPressed: () => onSendMessage(
                  textEditingController.text,
                  "text",
                  null,
                ),
                color: FlatColors.webblenRed,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: FlatColors.clouds,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  Widget postView() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          youtubeVideoID != null
              ? YoutubePlayer(
                  width: MediaQuery.of(context).size.width,
                  controller: vidController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.amber,
                  progressColors: ProgressBarColors(
                    playedColor: Colors.amber,
                    handleColor: Colors.amberAccent,
                  ),
                  onReady: () {
                    print('Player is ready.');
                  },
                )
              : widget.newsPost.imageURL == null
                  ? Container()
                  : CachedNetworkImage(
                      imageUrl: widget.newsPost.imageURL,
                      fit: BoxFit.cover,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                    ),
          postAuthor(),
          postContent(),
        ],
      ),
    );
  }

  Widget buildCommmentsList() {
    return Flexible(
      child: StreamCommentData(
        currentUser: widget.currentUser,
        postID: widget.newsPost.postID,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.newsPost.newsURL != null && widget.newsPost.newsURL.contains('youtube.com')) {
      youtubeVideoID = YoutubePlayer.convertUrlToId(widget.newsPost.newsURL);
      vidController = YoutubePlayerController(
        initialVideoId: youtubeVideoID,
        flags: YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          //forceHideAnnotation: true,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        "News Chat",
        widget.currentUser.username == widget.newsPost.username
            ? IconButton(
                icon: Icon(
                  FontAwesomeIcons.trash,
                  size: 16.0,
                  color: Colors.black38,
                ),
                onPressed: () => ShowAlertDialogService().showConfirmationDialog(context, "Delete this Post?", "Delete", () {
                  Navigator.of(context).pop();
                  ShowAlertDialogService().showLoadingDialog(context);
                  CommunityDataService()
                      .deletePost(
                    widget.newsPost.postID,
                    widget.newsPost.areaName,
                    widget.newsPost.communityName,
                  )
                      .then((error) {
                    if (error.isNotEmpty) {
                      Navigator.of(context).pop();
                      ShowAlertDialogService().showFailureDialog(
                        context,
                        "Uh Oh!",
                        "There was an issue deleting this post. Please Try Again.",
                      );
                    } else {
                      CommentDataService().deleteComments(widget.newsPost.postID);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  });
                }, () {
                  Navigator.of(context).pop();
                }),
              )
            : Container(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: postView(),
                ),
                Container(
                  height: 330,
                  color: FlatColors.iosOffWhite,
                  width: MediaQuery.of(context).size.width,
                  child: StreamCommentData(
                    currentUser: widget.currentUser,
                    postID: widget.newsPost.postID,
                    scrollController: listScrollController,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: buildInput(),
                ),
              ],
            ), // Loading
          ],
        ),
      ),
    );
  }
}
