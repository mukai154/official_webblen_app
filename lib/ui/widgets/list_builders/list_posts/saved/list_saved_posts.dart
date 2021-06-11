import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_view.dart';

import 'list_saved_posts_model.dart';

class ListSavedPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListSavedPostsModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ListSavedPostsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? ZeroStateView(
                  scrollController: model.scrollController,
                  imageAssetName: "",
                  imageSize: 200,
                  header: "No Posts Saved",
                  subHeader: "Save posts to view them here",
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
                      controller: model.scrollController,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        key: PageStorageKey(model.listKey),
                        addAutomaticKeepAlives: true,
                        shrinkWrap: true,
                        itemCount: model.dataResults.length + 1,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> snapshotData = model.dataResults[index].data() as Map<String, dynamic>;
                          if (index < model.dataResults.length) {
                            WebblenPost post;
                            post = WebblenPost.fromMap(snapshotData);
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
