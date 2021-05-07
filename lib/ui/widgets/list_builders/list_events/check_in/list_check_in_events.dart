import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/events/event_check_in_block/event_check_in_block.dart';

import 'list_check_in_events_model.dart';

class ListCheckInEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListCheckInEventsModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ListCheckInEventsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              'assets/images/modern_city.png',
                              height: 200,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ),
                      CustomText(
                        text: "You are not near any active events",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appFontColorAlt(),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: screenHeight(context),
                  color: appBackgroundColor(),
                  child: LiquidPullToRefresh(
                    backgroundColor: appBackgroundColor(),
                    color: appActiveColor(),
                    onRefresh: model.refreshData,
                    child: ListView.builder(
                      cacheExtent: 8000,
                      controller: model.scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      key: PageStorageKey(model.listKey),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemCount: model.dataResults.length + 1,
                      itemBuilder: (context, index) {
                        if (index < model.dataResults.length) {
                          WebblenEvent event;
                          event = WebblenEvent.fromMap(model.dataResults[index].data()!);
                          return EventCheckInBlock(
                            event: event,
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
    );
  }
}
