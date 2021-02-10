import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/user_widgets/user_profile_pic.dart';
import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view_model.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/utils/time_calc.dart';

class PostImgBlockView extends StatelessWidget {
  final WebblenPost post;

  PostImgBlockView({
    this.post,
  });

  Widget head(PostImgBlockViewModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 16.0),
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
                post.city == null
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
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.mapMarkerAlt,
                                size: 10,
                                color: appFontColorAlt(),
                              ),
                              Text(
                                ' ${post.city}, ${post.province}',
                                style: TextStyle(
                                  color: appFontColorAlt(),
                                  fontSize: 12,
                                ),
                              ),
                            ],
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

  Widget postImg(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: post.imageURL,
      height: screenWidth(context),
      width: screenWidth(context),
      fadeInCurve: Curves.easeIn,
      filterQuality: FilterQuality.high,
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
                color: appIconColor(),
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

  Widget postMessage(PostImgBlockViewModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.0,
            color: appFontColor(),
          ),
          children: <TextSpan>[
            TextSpan(
              text: '@${model.authorUsername} ',
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

  Widget postTags(PostImgBlockViewModel model) {
    return Container(
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
    return ViewModelBuilder<PostImgBlockViewModel>.reactive(
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      viewModelBuilder: () => PostImgBlockViewModel(),
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
              postImg(context),
              commentCountAndPostTime(),
              postMessage(model),
              verticalSpaceSmall,
              postTags(model),
              Divider(
                thickness: 4.0,
                color: appPostBorderColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
