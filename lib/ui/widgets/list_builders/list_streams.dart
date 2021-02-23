import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_stream.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/streams/stream_block/stream_block_widget.dart';

class ListStreams extends StatelessWidget {
  final List dataResults;
  final VoidCallback refreshData;
  final PageStorageKey pageStorageKey;
  final ScrollController scrollController;
  ListStreams({@required this.refreshData, @required this.dataResults, @required this.pageStorageKey, @required this.scrollController});

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
          WebblenStream stream;
          bool displayBottomBorder = true;

          ///GET CAUSE OBJECT
          if (dataResults[index] is DocumentSnapshot) {
            stream = WebblenStream.fromMap(dataResults[index].data());
          } else {
            stream = dataResults[index];
          }

          ///DISPLAY BOTTOM BORDER
          if (dataResults.last == dataResults[index]) {
            displayBottomBorder = false;
          }
          return StreamBlockWidget(
            stream: stream,
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
