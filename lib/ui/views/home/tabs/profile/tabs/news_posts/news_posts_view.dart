import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/views/posts/post_block/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/views/posts/post_block/post_text_block/post_text_block_view.dart';

class ProfileNewsPostsView extends StatelessWidget {
  final List postResults;
  final VoidCallback refreshData;
  ProfileNewsPostsView({this.refreshData, this.postResults});

  Widget listPosts() {
    return LiquidPullToRefresh(
      onRefresh: refreshData,
      child: ListView.builder(
        key: PageStorageKey('profile-posts'),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: postResults.length,
        itemBuilder: (context, index) {
          WebblenPost post = WebblenPost.fromMap(postResults[index].data());
          return post.imageURL == null ? PostTextBlockView(post: post) : PostImgBlockView(post: post);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: appBackgroundColor(),
      child: listPosts(),
    );
  }
}
