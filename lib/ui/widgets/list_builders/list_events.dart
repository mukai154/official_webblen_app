import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/events/event_block/event_block_widget.dart';

class ListEvents extends StatelessWidget {
  final List dataResults;
  final VoidCallback refreshData;
  final PageStorageKey pageStorageKey;
  final ScrollController scrollController;
  ListEvents({@required this.refreshData, @required this.dataResults, @required this.pageStorageKey, @required this.scrollController});

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
          bool displayBottomBorder = true;

          ///GET CAUSE OBJECT
          if (dataResults[index] is DocumentSnapshot) {
            event = WebblenEvent.fromMap(dataResults[index].data());
          } else {
            event = dataResults[index];
          }

          ///DISPLAY BOTTOM BORDER
          if (dataResults.last == dataResults[index]) {
            displayBottomBorder = false;
          }
          return EventBlockWidget(
            event: event,
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