import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:webblen/firebase_data/comment_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/comment.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_comment/comment_row.dart';

class StreamCommentData extends StatelessWidget {
  final WebblenUser currentUser;
  final String postID;
  final ScrollController scrollController;

  StreamCommentData({
    this.currentUser,
    this.postID,
    this.scrollController,
  });

  final CollectionReference commentRef =
      Firestore.instance.collection('comments');

  transitionToUserPage(BuildContext context, String uid) async {
    UserDataService().getUserByID(uid).then((user) {
      if (user != null) {
        PageTransitionService(
          context: context,
          currentUser: currentUser,
          webblenUser: user,
        ).transitionToUserDetailsPage();
      }
    });
  }

  deleteCommentDialog(BuildContext context, Comment comment) {
    ShowAlertDialogService().showConfirmationDialog(
      context,
      "Delete Comment?",
      "Delete",
      () {
        CommentDataService().deleteComment(comment.commentKey).then((error) {
          if (error.isNotEmpty) {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(
              context,
              'Uh oh...',
              'There was an issue deleting this comment.',
            );
          } else {
            Navigator.of(context).pop();
          }
        });
      },
      () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: commentRef
          .where(
            'postID',
            isEqualTo: postID,
          )
          .orderBy(
            'postDateInMilliseconds',
            descending: true,
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Comment> comments = [];
        if (!snapshot.hasData) {
          return Center(
            child: Fonts().textW300(
              'Loading...',
              18.0,
              FlatColors.lightAmericanGray,
              TextAlign.center,
            ),
          );
        } else {
          if (snapshot.data.documents.isEmpty)
            return Center(
              child: Fonts().textW300(
                'This post has no comments',
                18.0,
                FlatColors.lightAmericanGray,
                TextAlign.center,
              ),
            );
          snapshot.data.documents.forEach((comDoc) {
            Comment comment = Comment.fromMap(comDoc.data);
            if (!comments.contains(comment)) {
              comments.add(comment);
            }
          });
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,
            ),
            itemCount: comments.length,
            reverse: true,
            controller: scrollController,
            itemBuilder: (context, index) {
              if (comments[index].contentType == 'start') {
                return StartRow(
                  comment: comments[index],
                );
              } else if (currentUser.uid == comments[index].uid) {
                return CurrentUserCommentRow(
                  comment: comments[index],
                  deleteAction: () => deleteCommentDialog(
                    context,
                    comments[index],
                  ),
                );
              } else {
                return CommentRow(
                  comment: comments[index],
                  onClickAction: () => transitionToUserPage(
                    context,
                    comments[index].uid,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}

class StreamCommentCountData extends StatelessWidget {
  final String postID;

  StreamCommentCountData({
    this.postID,
  });

  final CollectionReference commentRef =
      Firestore.instance.collection('comments');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: commentRef
          .where(
            'postID',
            isEqualTo: postID,
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(
              top: 8.0,
            ),
            child: Fonts().textW500(
              '...',
              18.0,
              FlatColors.lightAmericanGray,
              TextAlign.center,
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(
              top: 8.0,
            ),
            child: Fonts().textW500(
              '${snapshot.data.documents.length - 1}',
              18.0,
              FlatColors.lightAmericanGray,
              TextAlign.center,
            ),
          );
        }
      },
    );
  }
}

class StreamRequestCommentData extends StatelessWidget {
  final WebblenUser currentUser;
  final String requestID;
  final ScrollController scrollController;

  StreamRequestCommentData({
    this.currentUser,
    this.requestID,
    this.scrollController,
  });

  final CollectionReference commentRef =
      Firestore.instance.collection('request_comments');

  transitionToUserPage(BuildContext context, String uid) async {
    UserDataService().getUserByID(uid).then((user) {
      if (user != null) {
        PageTransitionService(
          context: context,
          currentUser: currentUser,
          webblenUser: user,
        ).transitionToUserDetailsPage();
      }
    });
  }

  deleteCommentDialog(BuildContext context, Comment comment) {
    ShowAlertDialogService().showConfirmationDialog(
      context,
      "Delete Comment?",
      "Delete",
      () {
        CommentDataService().deleteComment(comment.commentKey).then((error) {
          if (error.isNotEmpty) {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(
              context,
              'Uh oh...',
              'There was an issue deleting this comment.',
            );
          } else {
            Navigator.of(context).pop();
          }
        });
      },
      () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: commentRef
          .where(
            'requestID',
            isEqualTo: requestID,
          )
          //.orderBy('postDateInMilliseconds', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Comment> comments = [];
        if (!snapshot.hasData) {
          return Center(
            child: Fonts().textW300(
              'Loading...',
              18.0,
              FlatColors.lightAmericanGray,
              TextAlign.center,
            ),
          );
        } else {
          if (snapshot.data.documents.isEmpty)
            return Center(
              child: Fonts().textW300(
                'This post has no comments',
                18.0,
                FlatColors.lightAmericanGray,
                TextAlign.center,
              ),
            );
          snapshot.data.documents.forEach((comDoc) {
            Comment comment = Comment.fromMap(comDoc.data);
            if (!comments.contains(comment)) {
              comments.add(comment);
            }
          });
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,
            ),
            itemCount: comments.length,
            reverse: true,
            controller: scrollController,
            itemBuilder: (context, index) {
              if (comments[index].contentType == 'start') {
                return StartRow(
                  comment: comments[index],
                );
              } else if (currentUser.uid == comments[index].uid) {
                return CurrentUserCommentRow(
                  comment: comments[index],
                  deleteAction: () => deleteCommentDialog(
                    context,
                    comments[index],
                  ),
                );
              } else {
                return CommentRow(
                  comment: comments[index],
                  onClickAction: () => transitionToUserPage(
                    context,
                    comments[index].uid,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}

class StreamRequestCommentCountData extends StatelessWidget {
  final String requestID;

  StreamRequestCommentCountData({
    this.requestID,
  });

  final CollectionReference commentRef =
      Firestore.instance.collection('request_comments');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: commentRef
          .where(
            'requestID',
            isEqualTo: requestID,
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(
              top: 8.0,
            ),
            child: Fonts().textW500(
              '...',
              18.0,
              FlatColors.lightAmericanGray,
              TextAlign.center,
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(
              top: 4.0,
            ),
            child: Fonts().textW500(
              '${snapshot.data.documents.length - 1 == -1 ? 0 : snapshot.data.documents.length - 1}',
              14.0,
              FlatColors.lightAmericanGray,
              TextAlign.right,
            ),
          );
        }
      },
    );
  }
}
