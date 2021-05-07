import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_view.dart';

import 'list_full_post_search_results_model.dart';

class ListFullPostSearchResults extends StatelessWidget {
  final String searchTerm;
  ListFullPostSearchResults({required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListFullPostSearchResultsModel>.reactive(
      onModelReady: (model) => model.initialize(searchTerm),
      viewModelBuilder: () => ListFullPostSearchResultsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CustomText(
                    text: "No Results for \"$searchTerm\"",
                    textAlign: TextAlign.center,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appFontColorAlt(),
                  ),
                )
              : Container(
                  height: screenHeight(context),
                  color: appBackgroundColor(),
                  child: RefreshIndicator(
                    onRefresh: model.refreshData,
                    child: ListView.builder(
                      cacheExtent: 8000,
                      controller: model.scrollController,
                      key: PageStorageKey(model.listKey),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemCount: model.dataResults.length + 1,
                      itemBuilder: (context, index) {
                        if (index < model.dataResults.length) {
                          WebblenPost post = model.dataResults[index];
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
    );
  }
}
