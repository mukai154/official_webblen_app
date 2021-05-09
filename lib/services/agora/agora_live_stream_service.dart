import 'package:agora_rtc_engine/rtc_engine.dart';

class AgoraLiveStreamService {
  Future<String?> generateStreamToken(String streamID) async {
    String? token;
    return token;
  }

  //standard video config of 720x1280
  VideoEncoderConfiguration getVideoConfig() {
    VideoEncoderConfiguration vidConfig = VideoEncoderConfiguration(
      dimensions: VideoDimensions(720, 1280),
      frameRate: VideoFrameRate.Fps30,
      orientationMode: VideoOutputOrientationMode.FixedLandscape,
      bitrate: 1130,
    );
    return vidConfig;
  }
}
