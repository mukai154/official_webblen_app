import 'package:miniplayer/miniplayer.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/services/reactive/mini_video_player/reactive_mini_video_player_service.dart';

class MiniVideoPlayerViewModel extends BaseViewModel {
  ReactiveMiniVideoPlayerService _reactiveMiniVideoPlayerService = locator<ReactiveMiniVideoPlayerService>();

  ///STREAM DATA
  WebblenLiveStream get selectedStream => _reactiveMiniVideoPlayerService.selectedStream;
  String get selectedStreamCreator => _reactiveMiniVideoPlayerService.selectedStreamCreator;

  ///VIDEO PLAYER
  MiniplayerController miniplayerController = MiniplayerController();
  VideoPlayerController? videoPlayerController;
  VideoPlayer? videoPlayer;
  bool configuredVideoPlayer = false;
  bool videoBuffering = false;
  bool videoMuted = false;
  bool isExpanded = true;

  initialize() async {
    setBusy(true);
    //configure video player controller
    await Future.delayed(Duration(seconds: 2));
    try {
      videoPlayerController = VideoPlayerController.network(
        'https://stream.mux.com/${selectedStream.muxAssetPlaybackID}.m3u8',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await videoPlayerController!.initialize().then((_) {
        videoPlayerController!.setLooping(true);
      });

      videoPlayer = VideoPlayer(videoPlayerController!);
      configuredVideoPlayer = true;
    } catch (e) {
      configuredVideoPlayer = false;
    }

    notifyListeners();
    setBusy(false);
  }

  toggleVideoMute() {
    if (videoMuted) {
      videoMuted = false;
      videoPlayerController!.setVolume(1);
    } else {
      videoMuted = true;
      videoPlayerController!.setVolume(0);
    }
    notifyListeners();
  }

  pausePlayVideoPlayer() {
    if (videoPlayerController != null) {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
      } else {
        videoPlayerController!.play();
      }
    }
  }

  expandMiniPlayer() {
    miniplayerController.animateToHeight(
      state: PanelState.MAX,
    );
    isExpanded = true;
    notifyListeners();
  }

  shrinkMiniPlayer() {
    miniplayerController.animateToHeight(
      state: PanelState.MIN,
    );
    isExpanded = false;
    notifyListeners();
  }

  dismissMiniPlayer() async {
    if (videoPlayerController != null) {
      await videoPlayerController!.pause();
    }
    _reactiveMiniVideoPlayerService.clearState();
    notifyListeners();
  }
}
