import 'package:flutter/material.dart';
import 'package:webblen/models/comment.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:cached_network_image/cached_network_image.dart';


class StartRow extends StatelessWidget {

  final Comment comment;
  StartRow({this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: null,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 250),
                      child: Fonts().textW700('${comment.content}', 16.0, Colors.black38, TextAlign.left),
                    ),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}


class CommentRow extends StatelessWidget {

  final Comment comment;
  final VoidCallback onClickAction;
  CommentRow({this.comment, this.onClickAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onClickAction,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: UserDetailsProfilePic(userPicUrl: comment.userImageURL, size: 60.0),
                    ),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Fonts().textW700("@" + comment.username, 18.0, FlatColors.lightAmericanGray, TextAlign.left),
                    comment.contentType == "image"
                    ? CachedNetworkImage(
                      imageUrl: comment.content,
                      height: 150.0,
                      width: 150.0,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => Fonts().textW300('Could Not Retrieve Photo', 16.0, FlatColors.redOrange, TextAlign.left)
                    )
                    : Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 250),
                      child: Fonts().textW500('${comment.content}', 16.0, FlatColors.lightAmericanGray, TextAlign.left),
                    ),
                    SizedBox(height: 8),
                    Fonts().textW300('${TimeCalc().getPastTimeFromMilliseconds(comment.postDateInMilliseconds)}', 12.0, FlatColors.darkGray, TextAlign.left),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}

class CurrentUserCommentRow extends StatelessWidget {

  final Comment comment;
  final VoidCallback deleteAction;
  CurrentUserCommentRow({this.comment, this.deleteAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: GestureDetector(
        onLongPress: deleteAction,
        child: Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    comment.contentType == "image"
                        ? CachedNetworkImage(
                            imageUrl: comment.content,
                            height: 200.0,
                            width: 200.0,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => Fonts().textW300('${comment.content}', 16.0, FlatColors.redOrange, TextAlign.right)
                          )
                        : Container(
                          constraints: BoxConstraints(maxWidth: 230),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: FlatColors.webblenRed,
                            borderRadius: BorderRadius.all(Radius.circular(16.0))
                          ),
                          child: Fonts().textW500('${comment.content}', 16.0, Colors.white, TextAlign.right),
                        ),
                    SizedBox(height: 2),
                    Fonts().textW300('${TimeCalc().getPastTimeFromMilliseconds(comment.postDateInMilliseconds)}', 12.0, FlatColors.darkGray, TextAlign.right),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}
