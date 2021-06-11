import 'package:flutter/material.dart';
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
                  child: RefreshIndicator(
                    onRefresh: model.refreshData,
                    backgroundColor: appBackgroundColor(),
                    color: appFontColor(),
                    child: SingleChildScrollView(
                      controller: model.scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: screenHeight(context) - 300,
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
                                    height: 150,
                                    fit: BoxFit.fitHeight,
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
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            Map<String, dynamic> snapshotData = model.dataResults[index].data() as Map<String, dynamic>;
                            WebblenEvent event;
                            event = WebblenEvent.fromMap(snapshotData);
                            return EventCheckInBlock(
                              event: event,
                              showEventOptions: (event) => model.showContentOptions(event),
                            );
                          } else {
                            if (model.moreDataAvailable) {
                              WidgetsBinding.instance!.addPostFrameCallback((_) {
                                if (model.dataResults.length > 10) {
                                  model.loadAdditionalData();
                                }
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
