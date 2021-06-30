import 'package:flutter/material.dart';
import 'package:lazy_loading_list/lazy_loading_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/horizontal_feed/list_horizontal_streams_feed.dart';

import 'list_discover_content_model.dart';

class ListDiscoverContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListDiscoverContentModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ListDiscoverContentModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? ZeroStateView(
                  scrollController: model.scrollController,
                  imageAssetName: "modern_city",
                  imageSize: 200,
                  header: "No Posts, Streams, or Events in ${model.cityName} Found",
                  subHeader: "Create Something for ${model.cityName} Now!",
                  mainActionButtonTitle: "Create",
                  mainAction: () => model.customBottomSheetService.showAddContentOptions(),
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
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: model.dataResults.length + 1,
                      itemBuilder: (context, index) {
                        Map<String, dynamic>? snapshotData;
                        if (index != 0) {
                          snapshotData = model.dataResults[index - 1].data() as Map<String, dynamic>;
                        }
                        return LazyLoadingList(
                          key: PageStorageKey(model.listKey),
                          initialSizeOfItems: model.dataResults.length,
                          loadMore: () => model.loadAdditionalData(),
                          child: index == 0
                              ? _StreamsFeed()
                              : snapshotData!['postDateTimeInMilliseconds'] != null
                                  ? model.getPostWidget(snapshotData)
                                  : snapshotData['venueSize'] != null
                                      ? model.getEventWidget(snapshotData)
                                      : SizedBox(height: 0, width: 0),
                          index: index,
                          hasMore: model.moreDataAvailable,
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}

class _StreamsFeed extends HookViewModelWidget<ListDiscoverContentModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ListDiscoverContentModel model) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxHeight: 125,
          maxWidth: 500,
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: ListHorizontalStreamsFeed(),
        ),
      ),
    );
  }
}
