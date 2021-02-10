import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/user_widgets/user_profile_pic.dart';
import 'package:webblen/ui/views/posts/post_view/post_view_model.dart';
import 'package:webblen/ui/widgets/comments/comment_text_field_view.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/list_builders/list_comments.dart';
import 'package:webblen/utils/time_calc.dart';

class PostView extends StatelessWidget {
  final FocusNode focusNode = FocusNode();

  Widget postHead(PostViewModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () => model.navigateToUserView(model.author.id),
            child: Row(
              children: <Widget>[
                UserProfilePic(
                  isBusy: false,
                  userPicUrl: model.author.profilePicURL,
                  size: 35,
                ),
                horizontalSpaceSmall,
                Text(
                  "@${model.author.username}",
                  style: TextStyle(color: appFontColor(), fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget postImg(BuildContext context, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: screenWidth(context),
      width: screenWidth(context),
      fadeInCurve: Curves.easeIn,
      filterQuality: FilterQuality.high,
    );
  }

  Widget postMessage(PostViewModel model) {
    return model.post.imageURL == null
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomText(
              text: model.post.body,
              textAlign: TextAlign.left,
              color: appFontColor(),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: appFontColor(),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '@${model.author.username} ',
                    style: TextStyle(
                      color: appFontColor(),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: model.post.body.trim(),
                    style: TextStyle(
                      color: appFontColor(),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget postCommentCountAndTime(PostViewModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.comment,
                size: 16,
                color: appFontColor(),
              ),
              horizontalSpaceSmall,
              Text(
                model.post.commentCount.toString(),
                style: TextStyle(
                  fontSize: 18,
                  color: appFontColor(),
                ),
              ),
            ],
          ),
          Text(
            TimeCalc().getPastTimeFromMilliseconds(model.post.postDateTimeInMilliseconds),
            style: TextStyle(
              color: appFontColorAlt(),
            ),
          ),
        ],
      ),
    );
  }

  Widget postBody(BuildContext context, PostViewModel model) {
    return model.post.imageURL == null
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                verticalSpaceSmall,
                postHead(model),
                verticalSpaceSmall,
                postMessage(model),
                verticalSpaceSmall,
                postCommentCountAndTime(model),
                verticalSpaceSmall,
                Divider(
                  thickness: 8.0,
                  color: appPostBorderColor(),
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                verticalSpaceSmall,
                postHead(model),
                verticalSpaceSmall,
                postImg(context, model.post.imageURL),
                verticalSpaceSmall,
                postCommentCountAndTime(model),
                verticalSpaceSmall,
                postMessage(model),
                verticalSpaceSmall,
                Divider(
                  thickness: 8.0,
                  color: appPostBorderColor(),
                ),
              ],
            ),
          );
  }

  postComments(BuildContext context, PostViewModel model) {
    return ListComments(
      refreshData: () async {},
      scrollController: null,
      showingReplies: false,
      pageStorageKey: model.commentStorageKey,
      refreshingData: false,
      results: model.commentResults,
      replyToComment: (val) => model.toggleReply(focusNode, val),
      deleteComment: (val) => model.showDeleteCommentConfirmation(context: context, comment: val),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PostViewModel>.reactive(
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => PostViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: "Post",
          showBackButton: true,
          actionWidget: IconButton(
            onPressed: () => model.showPostOptions(),
            icon: Icon(
              FontAwesomeIcons.ellipsisH,
              size: 16,
              color: appIconColor(),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => model.unFocusKeyboard(context),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: model.isBusy
                ? Container()
                : Stack(
                    children: [
                      LiquidPullToRefresh(
                        backgroundColor: appBackgroundColor(),
                        onRefresh: () async {},
                        child: ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: model.postScrollController,
                          shrinkWrap: true,
                          children: [
                            postBody(context, model),
                            postComments(context, model),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: CommentTextFieldView(
                          onSubmitted: model.isReplying
                              ? (val) => model.replyToComment(
                                    context: context,
                                    commentVal: val,
                                  )
                              : (val) => model.submitComment(context: context, commentVal: val),
                          focusNode: focusNode,
                          commentTextController: model.commentTextController,
                          isReplying: model.isReplying,
                          replyReceiverUsername: model.isReplying ? model.commentToReplyTo.username : null,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
