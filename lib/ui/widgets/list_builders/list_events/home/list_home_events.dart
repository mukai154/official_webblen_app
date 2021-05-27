import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/events/event_block/event_block_view.dart';

import 'list_home_events_model.dart';

class ListHomeEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListHomeEventsModel>.reactive(
      fireOnModelReadyOnce: true,
      disposeViewModel: false,
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => locator<ListHomeEventsModel>(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? ZeroStateView(
                  scrollController: model.scrollController,
                  imageAssetName: "calendar",
                  imageSize: 200,
                  header: "No Events in ${model.cityName} Found",
                  subHeader: "Schedule an Event for ${model.cityName} Now!",
                  mainActionButtonTitle: "Create Event",
                  mainAction: () => model.customNavigationService.navigateToCreateEventView("new"),
                  secondaryActionButtonTitle: null,
                  secondaryAction: null,
                  refreshData: model.refreshData,
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
                          WebblenEvent event;
                          event = WebblenEvent.fromMap(model.dataResults[index].data()!);
                          return EventBlockView(
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
