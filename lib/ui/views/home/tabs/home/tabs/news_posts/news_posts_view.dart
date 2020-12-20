import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/views/posts/post_block/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/views/posts/post_block/post_text_block/post_text_block_view.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'news_posts_view_model.dart';

class NewsPostsView extends StatelessWidget {
  final WebblenUser user;
  final String areaCode;
  NewsPostsView({this.user, this.areaCode});

  Widget listPosts(ScrollController controller, NewsPostsViewModel model) {
    return model.isBusy
        ? Center(child: CustomCircleProgressIndicator(color: appActiveColor(), size: 30))
        : LiquidPullToRefresh(
            color: appActiveColor(),
            onRefresh: model.refreshData,
            child: ListView.builder(
              key: PageStorageKey('posts'),
              addAutomaticKeepAlives: true,
              controller: controller,
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 4.0,
                bottom: 4.0,
              ),
              itemCount: model.postResults.length,
              itemBuilder: (context, index) {
                WebblenPost post = WebblenPost.fromMap(model.postResults[index].data());
                return post.imageURL == null ? PostTextBlockView(post: post) : PostImgBlockView(post: post);
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewsPostsViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => locator<NewsPostsViewModel>(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: listPosts(model.postsScrollController, model),
      ),
    );
  }
}
