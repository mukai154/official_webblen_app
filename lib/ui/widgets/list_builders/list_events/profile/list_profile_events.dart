import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/events/event_block/event_block_view.dart';

import 'list_profile_events_model.dart';

class ListProfileEvents extends StatelessWidget {
  final String id;
  final bool isCurrentUser;
  ListProfileEvents({required this.id, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListProfileEventsModel>.reactive(
      onModelReady: (model) => model.initialize(
        uid: id,
      ),
      viewModelBuilder: () => ListProfileEventsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? isCurrentUser
                  ? ZeroStateView(
                      imageAssetName: "calendar",
                      imageSize: 200,
                      header: "You Do Not Have Any Events",
                      subHeader: "Schedule and New Event to Share with the Community",
                      mainActionButtonTitle: "Create Event",
                      mainAction: () => model.customNavigationService.navigateToCreateEventView("new"),
                      secondaryActionButtonTitle: null,
                      secondaryAction: null,
                      refreshData: model.refreshData,
                      scrollController: null,
                    )
                  : ZeroStateView(
                      scrollController: null,
                      imageAssetName: "umbrella_chair",
                      imageSize: 200,
                      header: "This Account Does Not Have Any Events",
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
                            Map<String, dynamic> snapshotData = model.dataResults[index].data() as Map<String, dynamic>;
                            WebblenEvent event;
                            event = WebblenEvent.fromMap(snapshotData);
                            return EventBlockView(
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
