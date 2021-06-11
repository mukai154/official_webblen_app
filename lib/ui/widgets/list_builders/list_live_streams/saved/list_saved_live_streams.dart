import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/live_streams/live_stream_block/live_stream_block_view.dart';

import 'list_saved_live_streams_model.dart';

class ListSavedLiveStreams extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListSavedLiveStreamsModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ListSavedLiveStreamsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? ZeroStateView(
                  scrollController: model.scrollController,
                  imageAssetName: "",
                  imageSize: 200,
                  header: "No Streams Saved",
                  subHeader: "Save streams to view them here",
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
                            WebblenLiveStream stream;
                            stream = WebblenLiveStream.fromMap(snapshotData);
                            return LiveStreamBlockView(
                              stream: stream,
                              showStreamOptions: (stream) => model.showContentOptions(stream),
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
