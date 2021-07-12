import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'expanded__landscape_mini_player_view_model.dart';

class ExpandedLandscapeMiniPlayerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExpandedLandscapeMiniPlayerViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ExpandedLandscapeMiniPlayerViewModel(),
      builder: (context, model, child) => Scaffold(
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: model.isBusy || model.miniVideoPlayerViewModel.isBusy
              ? Center(
                  child: CustomCircleProgressIndicator(
                    size: 20,
                    color: appActiveColor(),
                  ),
                )
              : _LandscapeVideoPlayer(),
        ),
      ),
    );
  }
}

class _LandscapeVideoPlayer extends HookViewModelWidget<ExpandedLandscapeMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedLandscapeMiniPlayerViewModel model) {
    return !model.miniVideoPlayerViewModel.videoPlayerController!.value.isInitialized
        ? Center(
            child: CustomCircleProgressIndicator(
              size: 20,
              color: appActiveColor(),
            ),
          )
        : Stack(
            children: [
              GestureDetector(
                onTap: () => model.miniVideoPlayerViewModel.pausePlayVideoPlayer(),
                child: AspectRatio(
                  aspectRatio: model.miniVideoPlayerViewModel.videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(model.miniVideoPlayerViewModel.videoPlayerController!),
                ),
              ),
              model.miniVideoPlayerViewModel.videoPlayerController!.value.isPlaying
                  ? Container()
                  : GestureDetector(
                      onTap: () => model.miniVideoPlayerViewModel.pausePlayVideoPlayer(),
                      child: AspectRatio(
                        aspectRatio: model.miniVideoPlayerViewModel.videoPlayerController!.value.aspectRatio,
                        child: model.miniVideoPlayerViewModel.videoPlayerController!.value.isBuffering
                            ? Center(
                                child: CustomCircleProgressIndicator(
                                  size: 20,
                                  color: Colors.white54,
                                ),
                              )
                            : model.miniVideoPlayerViewModel.videoPlayerController!.value.isPlaying
                                ? Container()
                                : Center(
                                    child: Icon(Icons.play_arrow, size: 30, color: Colors.white),
                                  ),
                      ),
                    ),
              Positioned(
                bottom: 8,
                left: 4,
                child: Container(
                  height: 20,
                  width: 20,
                  child: GestureDetector(
                    onTap: () => model.toggleLandscapeMode(),
                    child: Icon(
                      FontAwesomeIcons.compress,
                      color: Colors.white54,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  model.miniVideoPlayerViewModel.videoPlayerController!,
                  allowScrubbing: true,
                ),
              ),
            ],
          );
  }
}
