import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/events/event_block/event_block_view.dart';

class ListEvents extends StatelessWidget {
  final List dataResults;
  final VoidCallback refreshData;
  final PageStorageKey pageStorageKey;
  final ScrollController scrollController;
  final Function(WebblenEvent) showEventOptions;
  ListEvents(
      {@required this.refreshData,
      @required this.dataResults,
      @required this.pageStorageKey,
      @required this.scrollController,
      @required this.showEventOptions});

  Widget listData() {
    return RefreshIndicator(
      onRefresh: refreshData,
      backgroundColor: appBackgroundColor(),
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        key: pageStorageKey,
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: dataResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event;

          ///GET EVENT OBJECT
          if (dataResults[index] is DocumentSnapshot) {
            event = WebblenEvent.fromMap(dataResults[index].data());
          } else {
            event = dataResults[index];
          }

          return EventBlockWidget(
            event: event,
            showEventOptions: (event) => showEventOptions(event),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight(context),
      color: appBackgroundColor(),
      child: listData(),
    );
  }
}
