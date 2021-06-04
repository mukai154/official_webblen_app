import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_view.dart';

import 'list_profile_posts_model.dart';

class ListProfilePosts extends StatelessWidget {
  final String id;
  final bool isCurrentUser;
  ListProfilePosts({required this.id, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListProfilePostsModel>.reactive(
      onModelReady: (model) => model.initialize(
        uid: id,
      ),
      viewModelBuilder: () => ListProfilePostsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? isCurrentUser
                  ? ZeroStateView(
                      imageAssetName: "umbrella_chair",
                      imageSize: 200,
                      header: "You Do Not Have Any Posts",
                      subHeader: "Create a New Post to Share with the Community",
                      mainActionButtonTitle: "Create Post",
                      mainAction: () => model.customNavigationService.navigateToCreatePostView("new"),
                      secondaryActionButtonTitle: null,
                      secondaryAction: null,
                      refreshData: model.refreshData,
                      scrollController: null,
                    )
                  : ZeroStateView(
                      scrollController: null,
                      imageAssetName: "umbrella_chair",
                      imageSize: 200,
                      header: "This Account Has No Posts",
                      subHeader: "Check Back Later",
                      mainActionButtonTitle: "",
                      mainAction: null,
                      secondaryActionButtonTitle: null,
                      secondaryAction: null,
                      refreshData: model.refreshData,
                    )
              : Container(
                  height: screenHeight(context),
                  color: appBackgroundColor(),
                  child: RefreshIndicator(
                    onRefresh: model.refreshData,
                    backgroundColor: appBackgroundColor(),
                    color: appFontColorAlt(),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        key: PageStorageKey(model.listKey),
                        addAutomaticKeepAlives: true,
                        shrinkWrap: true,
                        itemCount: model.dataResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index < model.dataResults.length) {
                            WebblenPost post;
                            post = WebblenPost.fromMap(model.dataResults[index].data()!);
                            return post.imageURL == null
                                ? PostTextBlockView(
                                    post: post,
                                    showPostOptions: (post) => model.showContentOptions(post),
                                  )
                                : PostImgBlockView(
                                    post: post,
                                    showPostOptions: (post) => model.showContentOptions(post),
                                  );
                          } else {
                            if (model.moreDataAvailable) {
                              WidgetsBinding.instance!.addPostFrameCallback((_) {
                                model.loadAdditionalData();
                              });
                              return Align(
                                alignment: Alignment.center,
                                child: CustomCircleProgressIndicator(size: 10, color: appActiveColor()),
                              );
                            }
                            return Container();
                          }
                        },
                      ),
                    ),
                  ),
                ),
    );
  }
}
