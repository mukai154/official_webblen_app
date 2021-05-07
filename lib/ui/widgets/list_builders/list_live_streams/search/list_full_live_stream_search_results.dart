import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/live_streams/live_stream_block/live_stream_block_view.dart';

import 'list_full_live_stream_search_results_model.dart';

class ListFullLiveStreamSearchResults extends StatelessWidget {
  final String searchTerm;
  ListFullLiveStreamSearchResults({required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListFullLiveStreamSearchResultsModel>.reactive(
      onModelReady: (model) => model.initialize(searchTerm),
      viewModelBuilder: () => ListFullLiveStreamSearchResultsModel(),
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
                          return LiveStreamBlockView(
                            stream: model.dataResults[index],
                            showStreamOptions: (event) => model.showContentOptions(event),
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
