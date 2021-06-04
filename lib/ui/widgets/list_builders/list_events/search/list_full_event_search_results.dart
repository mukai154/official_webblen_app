import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/events/event_block/event_block_view.dart';

import 'list_full_event_search_results_model.dart';

class ListFullEventSearchResults extends StatelessWidget {
  final String searchTerm;
  ListFullEventSearchResults({required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListFullEventSearchResultsModel>.reactive(
      onModelReady: (model) => model.initialize(searchTerm),
      viewModelBuilder: () => ListFullEventSearchResultsModel(),
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
                          if (index < model.dataResults.length) {
                            return EventBlockView(
                              event: model.dataResults[index],
                              showEventOptions: (event) => model.showContentOptions(event),
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
