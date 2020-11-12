import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/comment_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_comment.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class CommentBlock extends StatefulWidget {
  final String currentUID;
  final String parentCommentID;
  final WebblenComment comment;
  final VoidCallback replyAction;
  final VoidCallback viewUser;
  final VoidCallback commentOptions;

  CommentBlock({
    this.currentUID,
    this.parentCommentID,
    this.comment,
    this.replyAction,
    this.viewUser,
    this.commentOptions,
  });

  @override
  _CommentBlockState createState() => _CommentBlockState();
}

class _CommentBlockState extends State<CommentBlock> {
  bool isLoading = true;
  bool showReplies = false;
  String authorProfilePicURL;
  String authorUsername;

  Widget listReplies() {
    return Container(
      //height: widget.comment.replies.length * 50.0,
      width: MediaQuery.of(context).size.width - 70,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.comment.replies.length,
        itemBuilder: (context, index) {
          WebblenComment reply = WebblenComment.fromMap(Map.from(widget.comment.replies[index]));
          return CommentBlock(
            viewUser: null,
            comment: reply,
            replyAction: null,
            parentCommentID: widget.comment.timePostedInMilliseconds.toString(),
            currentUID: widget.currentUID,
            commentOptions: () => showReplyOptions,
          );
        },
      ),
    );
  }

  void showReplyOptions(WebblenComment comment) async {
    HapticFeedback.lightImpact();
    String action = await showModalActionSheet(
      context: context,
      actions: [
        SheetAction(label: "Delete Reply", key: 'deleteReply', isDestructiveAction: true),
      ],
    );
    if (action == 'deleteReply') {
      OkCancelResult res = await showOkCancelAlertDialog(
        context: context,
        message: "Are You Sure You Want to Delete This Reply?",
        okLabel: "Delete",
        cancelLabel: "Cancel",
        isDestructiveAction: true,
      );
      if (res == OkCancelResult.ok) {
        CommentDataService().deleteReply(widget.comment.postID, widget.parentCommentID, comment);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WebblenUserData().getUserByID(widget.comment.senderUID).then((res) {
      authorProfilePicURL = res.profile_pic;
      authorUsername = res.username;
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: widget.comment.isReply ? EdgeInsets.only(top: 0.0) : EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: widget.viewUser,
              child: Row(
                children: <Widget>[
                  isLoading
                      ? Shimmer.fromColors(
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                          baseColor: CustomColors.iosOffWhite,
                          highlightColor: Colors.white,
                        )
                      : UserDetailsProfilePic(
                          userPicUrl: authorProfilePicURL,
                          size: widget.comment.isReply ? 20 : 35,
                        ),
                  SizedBox(
                    width: 10.0,
                  ),
                ],
              ),
            ),
            isLoading
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onDoubleTap: widget.commentOptions,
                        child: Container(
                          width: widget.comment.isReply ? MediaQuery.of(context).size.width - 120 : MediaQuery.of(context).size.width - 74,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '$authorUsername ',
                                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: widget.comment.message,
                                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            TimeCalc().getPastTimeFromMilliseconds(widget.comment.timePostedInMilliseconds),
                            style: TextStyle(color: Colors.black54, fontSize: 12.0, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8.0),
                          widget.replyAction == null
                              ? Container()
                              : GestureDetector(
                                  onTap: widget.replyAction,
                                  child: Text(
                                    "Reply",
                                    style: TextStyle(color: Colors.black54, fontSize: 12.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                          widget.comment.senderUID == widget.currentUID && widget.comment.isReply
                              ? GestureDetector(
                                  onTap: () => showReplyOptions(widget.comment),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red[300], fontSize: 12.0, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      SizedBox(height: 8),
                      widget.comment.replies.length > 0
                          ? showReplies
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      showReplies = false;
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Hide ${widget.comment.replies.length} replies",
                                      style: TextStyle(color: Colors.black54, fontSize: 12.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    showReplies = true;
                                    setState(() {});
                                  },
                                  child: Text(
                                    "- Show ${widget.comment.replies.length} replies",
                                    style: TextStyle(color: Colors.black54, fontSize: 12.0, fontWeight: FontWeight.bold),
                                  ),
                                )
                          : Container(),
                      widget.comment.replies.length > 0 && showReplies ? listReplies() : Container(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
