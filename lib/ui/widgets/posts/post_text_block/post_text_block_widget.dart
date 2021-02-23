import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/user_widgets/user_profile_pic.dart';
import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_model.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/utils/time_calc.dart';

class PostTextBlockWidget extends StatelessWidget {
  final WebblenPost post;

  PostTextBlockWidget({
    this.post,
  });

  Widget head(PostTextBlockModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: null,
            child: Row(
              children: <Widget>[
                UserProfilePic(
                  userPicUrl: model.authorImageURL,
                  size: 35,
                  isBusy: false,
                ),
                SizedBox(
                  width: 10.0,
                ),
                post.tags.isEmpty
                    ? Text(
                        "@${model.authorUsername}",
                        style: TextStyle(
                          color: appFontColor(),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "@${model.authorUsername}",
                            style: TextStyle(
                              color: appFontColor(),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            post.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                            style: TextStyle(
                              fontSize: 14,
                              color: appFontColorAlt(),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () => model.showOptions(
              post: post,
              refreshAction: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget postBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        post.body,
        style: TextStyle(
          color: appFontColor(),
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget commentCountAndPostTime() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
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
              SizedBox(
                width: 8.0,
              ),
              Text(
                post.commentCount.toString(),
                style: TextStyle(
                  fontSize: 18,
                  color: appFontColor(),
                ),
              ),
            ],
          ),
          Text(
            TimeCalc().getPastTimeFromMilliseconds(post.postDateTimeInMilliseconds),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget postMessage(PostTextBlockModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: '',
              style: TextStyle(
                color: appFontColor(),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: post.body.trim(),
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

  Widget postTags(PostTextBlockModel model) {
    return post.tags.isEmpty
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            height: 30,
            child: ListView.builder(
              addAutomaticKeepAlives: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 4.0,
                bottom: 4.0,
              ),
              itemCount: post.tags.length,
              itemBuilder: (context, index) {
                return TagButton(
                  onTap: null,
                  tag: post.tags[index],
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PostTextBlockModel>.reactive(
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      viewModelBuilder: () => PostTextBlockModel(),
      onModelReady: (model) => model.initialize(post.authorID),
      builder: (context, model, child) => GestureDetector(
        onTap: () => model.navigateToPostView(post.id),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              head(model),
              postBody(),
              commentCountAndPostTime(),
              verticalSpaceSmall,
              postTags(model),
              Divider(
                thickness: 4.0,
                color: appDividerColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
