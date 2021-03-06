import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AgoraLiveStreamService {
  Future<String?> generateStreamToken({required String channelName, required String uid, required String role}) async {
    String? token;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'generateAgoraToken',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'channelName': channelName,
      'uid': uid,
      'role': role,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
      token = result.data;
    }
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

  LiveTranscoding configureTranscoding(int uid) {
    String watermarkAddress = 'https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/app_images%2FtinyLogo'
        '.png?alt=media&token=c8fdcce3-34a7-4455-b07f-8daf254a65be';
    TranscodingUser transcodingUser = TranscodingUser(uid, 0, 0, width: 1280, height: 720, audioChannel: AudioChannel.Channel0, alpha: 1, zOrder: 0);
    List<TranscodingUser> transcodingUsers = [transcodingUser];
    LiveTranscoding transcoding = LiveTranscoding(transcodingUsers);
    transcoding.audioBitrate = 96;
    transcoding.videoBitrate = 3000;
    transcoding.videoFramerate = VideoFrameRate.Fps30;
    transcoding.width = 1280;
    transcoding.height = 720;
    transcoding.videoCodecProfile = VideoCodecProfileType.Main;
    transcoding.transcodingUsers = transcodingUsers;
    transcoding.watermark = AgoraImage(watermarkAddress, 1220, 660, 50, 50);
    return transcoding;
  }
}
