import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/live_streams/live_stream_block/live_stream_block_view.dart';

class ListLiveStreams extends StatelessWidget {
  final List dataResults;
  final VoidCallback refreshData;
  final PageStorageKey pageStorageKey;
  final ScrollController scrollController;
  final Function(WebblenLiveStream) showStreamOptions;
  ListLiveStreams(
      {@required this.refreshData,
      @required this.dataResults,
      @required this.pageStorageKey,
      @required this.scrollController,
      @required this.showStreamOptions});

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
          WebblenLiveStream stream;

          ///GET CAUSE OBJECT
          if (dataResults[index] is DocumentSnapshot) {
            stream = WebblenLiveStream.fromMap(dataResults[index].data());
          } else {
            stream = dataResults[index];
          }

          return LiveStreamBlockView(
            stream: stream,
            showStreamOptions: (stream) => showStreamOptions(stream),
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
