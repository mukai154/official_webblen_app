import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_view.dart';

class ListPosts extends StatelessWidget {
  final String? currentUID;
  final List postResults;
  final Function(WebblenPost) showPostOptions;
  final VoidCallback refreshData;
  final PageStorageKey pageStorageKey;
  final ScrollController scrollController;
  ListPosts({
    required this.currentUID,
    required this.showPostOptions,
    required this.refreshData,
    required this.postResults,
    required this.pageStorageKey,
    required this.scrollController,
  });

  Widget listPosts() {
    return LiquidPullToRefresh(
      onRefresh: refreshData as Future<void> Function(),
      child: ListView.builder(
        controller: scrollController,
        key: pageStorageKey,
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: postResults.length,
        itemBuilder: (context, index) {
          WebblenPost post;
          if (postResults[index] is WebblenPost) {
            post = postResults[index];
          } else {
            post = WebblenPost.fromMap(postResults[index].data());
          }

          return post.imageURL == null
              ? PostTextBlockView(
                  currentUID: currentUID,
                  post: post,
                  showPostOptions: (post) => showPostOptions(post),
                )
              : PostImgBlockView(
                  currentUID: currentUID,
                  post: post,
                  showPostOptions: (post) => showPostOptions(post),
                );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight(context),
      color: appBackgroundColor(),
      child: listPosts(),
    );
  }
}
