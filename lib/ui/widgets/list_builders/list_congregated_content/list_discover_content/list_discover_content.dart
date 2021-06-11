import 'package:flutter/material.dart';
import 'package:lazy_loading_list/lazy_loading_list.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';

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
                      itemCount: model.dataResults.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> snapshotData = model.dataResults[index].data() as Map<String, dynamic>;
                        return LazyLoadingList(
                          key: PageStorageKey(model.listKey),
                          initialSizeOfItems: model.dataResults.length,
                          loadMore: () => model.loadAdditionalData(),
                          child: snapshotData['postDateTimeInMilliseconds'] != null
                              ? model.getPostWidget(snapshotData)
                              : snapshotData['hostID'] != null
                                  ? model.getStreamWidget(snapshotData)
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
