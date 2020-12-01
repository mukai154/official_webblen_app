import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/comment_data.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/post_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/models/webblen_comment.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/comments/comment_block.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/posts/post_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_profile_pic.dart';

class PostViewPage extends StatefulWidget {
  final String postID;

  PostViewPage({
    this.postID,
  });

  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  WebblenUser currentUser;
  bool isLoading = true;
  WebblenPost post;
  String replyingToCommentID;
  String replyReceiverUsername;
  bool isReplying = false;
  FocusNode messageFieldFocusNode = FocusNode();
  TextEditingController commentMessageController = TextEditingController();

  Widget postTags() {
    return Container();
  }

  void showPostOptions() async {
    if (post.authorID == currentUser.uid) {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Edit Post", key: 'editPost'),
          SheetAction(label: "Copy Link", key: 'copyLink'),
          SheetAction(label: "Share", key: 'sharePost'),
          SheetAction(label: "Delete Post", key: 'deletePost', isDestructiveAction: true),
        ],
      );
      if (action == 'editPost') {
        PageTransitionService(context: context, postID: post.id).transitionToCreatePostPage();
      } else if (action == 'copyLink') {
        ShareService().shareContent(post: post, copyLink: true);
        HapticFeedback.mediumImpact();
      } else if (action == 'sharePost') {
        ShareService().shareContent(post: post, copyLink: false);
      } else if (action == 'deletePost') {
        OkCancelResult res = await showOkCancelAlertDialog(
          context: context,
          message: "Delete This Post?",
          okLabel: "Delete",
          cancelLabel: "Cancel",
          isDestructiveAction: true,
        );
        if (res == OkCancelResult.ok) {
          PostDataService().deletePost(post.id);
        }
      }
    } else {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Copy Link", key: 'copyLink'),
          SheetAction(label: "Share", key: 'share'),
          SheetAction(label: "Report", key: 'report', isDestructiveAction: true),
        ],
      );
      if (action == 'copyLink') {
        ShareService().shareContent(post: post, copyLink: true);
        HapticFeedback.mediumImpact();
      } else if (action == 'share') {
        ShareService().shareContent(post: post, copyLink: false);
      } else if (action == 'report') {
        //PageTransitionService(context: context, isStream: true).transitionToCreatePostPage();
      }
    }
  }

  Widget postComments() {
    return Container(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("comments")
            .doc(post.id)
            .collection("comments")
            .orderBy("timePostedInMilliseconds", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> res) {
          if (!res.hasData) return Container();
          List<QueryDocumentSnapshot> query = res.data.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: query.length,
            itemBuilder: (context, index) {
              WebblenComment comment = WebblenComment.fromMap(query[index].data());
              return CommentBlock(
                viewUser: null,
                comment: comment,
                currentUID: currentUser.uid,
                commentOptions: () => showCommentOptions(comment),
                replyAction: () => replyToCommentAction(query[index].id, comment.username),
              );
            },
          );
        },
      ),
    );
  }

  void showCommentOptions(WebblenComment comment) async {
    HapticFeedback.lightImpact();
    if (comment.senderUID == currentUser.uid) {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Delete Comment", key: 'deleteComment', isDestructiveAction: true),
        ],
      );
      if (action == 'editComment') {
        //PageTransitionService(context: context, postID: postID).transitionToCreatePostPage();
      } else if (action == 'deleteComment') {
        OkCancelResult res = await showOkCancelAlertDialog(
          context: context,
          message: "Are You Sure You Want to Delete This Comment?",
          okLabel: "Delete",
          cancelLabel: "Cancel",
          isDestructiveAction: true,
        );
        if (res == OkCancelResult.ok) {
          if (comment.isReply) {
            CommentDataService().deleteReply(post.id, comment.originalReplyCommentID, comment);
          } else {
            CommentDataService().deleteComment(post.id, comment);
          }
        }
      }
    } else {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Report", key: 'report', isDestructiveAction: true),
        ],
      );
      if (action == 'report') {
        // PageTransitionService(context: context, isStream: true).transitionToCreatePostPage();
      }
    }
  }

  void addTagsToUserInterests() {}

  void shareLinkAction() async {
    Navigator.of(context).pop();
    Share.share("https://app.webblen.io/#/event?id=${post.id}");
//    DynamicLinks().createDynamicLink(event.id, event.title, event.desc, event.imageURL).then((link) {
//      Navigator.of(context).pop();
//      Share.share("https://app.webblen.io/#/event?id=${event.id}");
//    });
  }

  void deletePostAction() {}

  clearState() {
    isReplying = false;
    replyReceiverUsername = null;
    replyingToCommentID = null;
    setState(() {});
  }

  dismissKeyboard() {
    clearState();
    FocusScope.of(context).unfocus();
  }

  replyToCommentAction(String commentID, String username) {
    isReplying = true;
    replyReceiverUsername = username;
    replyingToCommentID = commentID;
    setState(() {});
    FocusScope.of(context).requestFocus(messageFieldFocusNode);
  }

  Widget bottomBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 32,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.white,
              Colors.white54,
              Colors.white12,
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            UserProfilePic(
              userPicUrl: currentUser.profile_pic,
              size: 45,
            ),
            Container(
              height: isReplying ? 80 : 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isReplying
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border.all(
                              color: Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          margin: EdgeInsets.only(left: 8.0, bottom: 8.0),
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            'Replying to @$replyReceiverUsername',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 90,
                    margin: EdgeInsets.only(left: 8.0),
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: TextField(
                      focusNode: messageFieldFocusNode,
                      minLines: 1,
                      maxLines: 5,
                      maxLengthEnforced: true,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (val) {
                        String text = val.trim();
                        if (text.isNotEmpty) {
                          if (isReplying) {
                            WebblenComment comment = WebblenComment(
                              postID: post.id,
                              senderUID: currentUser.uid,
                              username: currentUser.username,
                              message: text,
                              isReply: true,
                              replies: [],
                              replyCount: 0,
                              replyReceiverUsername: replyReceiverUsername,
                              originalReplyCommentID: replyingToCommentID,
                              timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
                            );
                            CommentDataService().replyToComment(post.id, replyingToCommentID, comment);
                          } else {
                            WebblenComment comment = WebblenComment(
                              postID: post.id,
                              senderUID: currentUser.uid,
                              username: currentUser.username,
                              message: text,
                              isReply: false,
                              replies: [],
                              replyCount: 0,
                              timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
                            );
                            CommentDataService().sendComment(post.id, comment);
                          }
                          clearState();
                        }
                        commentMessageController.clear();
                        setState(() {});
                      },
                      style: TextStyle(color: Colors.white),
                      controller: commentMessageController, //messageFieldController,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(150),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Comment',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  viewParent() {
    EventDataService().getEvent(post.parentID).then((res) {
      if (res != null) {
        PageTransitionService(context: context, eventID: post.parentID, currentUser: currentUser).transitionToEventPage();
      } else {
        showOkAlertDialog(
          context: context,
          message: "This Event No Longer Exists",
          okLabel: "Ok",
          barrierDismissible: true,
        );
      }
    });
  }

  transitionToUserPage(String uid) async {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenUser user = await WebblenUserData().getUserByID(uid);
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: currentUser,
      webblenUser: user,
    ).transitionToUserPage();
  }

  Future<void> loadPost() async {
    PostDataService().getPost(widget.postID).then((res) {
      if (res != null) {
        post = res;
      }
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      WebblenUserData().getUserByID(res).then((res) {
        currentUser = res;
        loadPost();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        "Post",
        IconButton(
          icon: Icon(
            FontAwesomeIcons.ellipsisH,
            size: 18.0,
            color: Colors.black,
          ),
          onPressed: () => showPostOptions(),
        ),
      ),
      body: isLoading
          ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed)
          : post == null
              ? Center(
                  child: Text(
                    'This Post No Longer Exists',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => dismissKeyboard(),
                        child: LiquidPullToRefresh(
                          color: CustomColors.webblenRed,
                          onRefresh: loadPost,
                          child: ListView(
                            children: [
                              post.imageURL != null
                                  ? PostImgBlock(
                                      viewUser: () => transitionToUserPage(post.authorID),
                                      postOptions: null,
                                      post: post,
                                      viewPost: null,
                                      viewParent: post.parentID == null ? null : () => viewParent(),
                                      showParentAction: post.parentID == null ? false : true,
                                    )
                                  : PostTextBlock(
                                      viewUser: () => transitionToUserPage(post.authorID),
                                      postOptions: null,
                                      post: post,
                                      viewPost: null,
                                      viewParent: post.parentID == null ? null : () => viewParent(),
                                      showParentAction: post.parentID == null ? false : true,
                                    ),
                              postTags(),
                              postComments(),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                      bottomBar(),
                    ],
                  ),
                ),
    );
  }
}
