import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/video_player/expanded_mini_player/expanded_mini_player_view.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'mini_video_player_view_model.dart';

class MiniVideoPlayerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MiniVideoPlayerViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => locator<MiniVideoPlayerViewModel>(),
      builder: (context, model, child) => Offstage(
        offstage: !model.selectedStream.isValid(),
        child: Miniplayer(
          controller: model.miniplayerController,
          maxHeight: screenHeight(context),
          minHeight: 80,
          builder: (height, percentage) {
            if (model.isBusy) {
              return Container(
                color: appBackgroundColor(),
                child: Center(
                  child: Container(
                    height: 20,
                    child: CustomCircleProgressIndicator(
                      size: 20,
                      color: appActiveColor(),
                    ),
                  ),
                ),
              );
            }
            if (height < screenHeight(context)) {
              return _MiniVideoPlayer();
            }
            return ExpandedMiniPlayerView();
          },
        ),
      ),
    );
  }
}

class _MiniVideoPlayer extends HookViewModelWidget<MiniVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, MiniVideoPlayerViewModel model) {
    return Container(
      color: appBackgroundColor(),
      child: !model.selectedStream.isValid()
          ? Container()
          : Stack(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 76,
                          child: GestureDetector(
                            onTap: () => model.pausePlayVideoPlayer(),
                            child: AspectRatio(
                              aspectRatio: model.videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(model.videoPlayerController!),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    model.selectedStream.title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: appFontColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    model.selectedStreamCreator,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: appFontColorAlt(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            model.videoPlayerController!.value.isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                            size: 18,
                            color: appIconColorAlt(),
                          ),
                          onPressed: () => model.pausePlayVideoPlayer(),
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.times,
                            size: 18,
                            color: appIconColorAlt(),
                          ),
                          onPressed: () => model.dismissMiniPlayer(),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    model.videoPlayerController!,
                    allowScrubbing: true,
                  ),
                ),
              ],
            ),
    );
  }
}
