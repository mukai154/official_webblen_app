import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_stream_chat_message.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/live_stream_chat_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/live_streaming/agora/agora_live_stream_service.dart';
import 'package:webblen/services/live_streaming/mux/mux_live_stream_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class LiveStreamHostViewModel extends StreamViewModel<WebblenLiveStream> {
  NavigationService? _navigationService = locator<NavigationService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  LiveStreamChatDataService? _liveStreamChatDataService =
      locator<LiveStreamChatDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService =
      locator<CustomNavigationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  AgoraLiveStreamService _agoraLiveStreamService = locator<AgoraLiveStreamService>();
  MuxLiveStreamService _muxLiveStreamService = locator<MuxLiveStreamService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///HELPERS
  final messageFieldController = TextEditingController();

  ///STREAM DATA
  WebblenLiveStream webblenLiveStream = WebblenLiveStream();
  bool liveStreamSetup = false;
  bool generatedToken = false;
  late RtcEngine agoraRtcEngine;
  bool muted = false;
  bool isInAgoraChannel = true;
  bool endingStream = false;
  List users = <int>[];
  String appID = '60693de17bbe4f2598f9f465d1695de1';
  String muxStreamURL = 'rtmps://global-live.mux.com:443/app/';

  ///CHAT
  int startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  ///GIFTING ANIMATION
  AnimationController? giftAnimationController;
  Animation? giftAnimation;

  initialize(String id) async {
    setBusy(true);

    //Set Device Orientation
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    //get stream data
    if (id.isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Stream Error',
        message:
            "There was an unknown error starting your stream. Please try again later.",
        duration: Duration(seconds: 5),
      );
      _navigationService!.back();
      return;
    } else {
      webblenLiveStream = await _liveStreamDataService.getStreamByID(id);
      if (!webblenLiveStream.isValid()) {
        _snackbarService!.showSnackbar(
          title: 'Stream Error',
          message:
              "There was an unknown error starting your stream. Please try again later.",
          duration: Duration(seconds: 5),
        );
        _navigationService!.back();
        return;
      }
    }

    //join chat
    _liveStreamChatDataService!.joinChatStream(
        streamID: webblenLiveStream.id,
        uid: user.id,
        isHost: true,
        username: user.username);
  }

  Future<bool> initializeAgoraRtc() async {
    bool initialized = true;
    RtcEngineConfig config = RtcEngineConfig(appID);

    agoraRtcEngine = await RtcEngine.createWithConfig(config).catchError((e) {
      print(e);
    });

    notifyListeners();

    await setAgoraRtcEventHandlers();
    VideoEncoderConfiguration vidConfig =
        _agoraLiveStreamService.getVideoConfig();

    await agoraRtcEngine.setVideoEncoderConfiguration(vidConfig);
    await agoraRtcEngine.enableVideo();
    await agoraRtcEngine.enableLocalAudio(true);

    await agoraRtcEngine.startPreview();
    await agoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await agoraRtcEngine.setClientRole(ClientRole.Broadcaster);

    String? token = await _agoraLiveStreamService.generateStreamToken(
        channelName: webblenLiveStream.id!, uid: user.id!, role: "PUBLISHER");
    if (token != null) {
      await agoraRtcEngine.joinChannelWithUserAccount(
          token, webblenLiveStream.id!, user.id!);
    } else {
      initialized = false;
    }

    notifyListeners();
    return initialized;
  }

  setAgoraRtcEventHandlers() async {
    agoraRtcEngine.setEventHandler(RtcEngineEventHandler(error: (code) {
      print(code);
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      //enable wakelock
      print('joinChannelSuccess $channel $uid $elapsed');
      print('publishing...');
      publishStreams(uid);
      await Wakelock.enable();
    }, leaveChannel: (stats) {
      //leave channel
      users.clear();
      notifyListeners();
    }, userJoined: (uid, elapsed) {
      //join channel
      print('userJoined $uid $elapsed');
      users.add(uid);
      notifyListeners();
    }, userOffline: (uid, elapsed) {
      //leave channel
      users.remove(uid);
      notifyListeners();
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      //video started
    }));
    return true;
  }

  publishStreams(int uid) async {
    String? muxStreamKey;
    String? muxStreamID;
    String? muxAssetPlaybackID;
    if (webblenLiveStream.muxStreamKey == null) {
      Map<String, dynamic>? muxData = await _muxLiveStreamService.createMuxStream(stream: webblenLiveStream);
      if (muxData != null) {
        muxStreamID = muxData['id'];
        muxStreamKey = muxData['stream_key'];
        muxAssetPlaybackID = muxData['playback_ids'][0]['id'];
        await _liveStreamDataService.updateStreamMuxStreamKey(
          streamID: webblenLiveStream.id!,
          muxStreamID: muxStreamID!,
          muxStreamKey: muxStreamKey!,
          muxAssetPlaybackID: muxAssetPlaybackID!,
        );
      }
    } else {
      muxStreamID = webblenLiveStream.muxStreamID;
      muxStreamKey = webblenLiveStream.muxStreamKey;
    }

    await Future.delayed(Duration(seconds: 3));

    ///stream to mux
    if (muxStreamID != null) {
      agoraRtcEngine.addPublishStreamUrl(muxStreamURL + muxStreamKey!, false);
    }
    if (webblenLiveStream.twitchStreamKey != null && webblenLiveStream.twitchStreamKey!.isNotEmpty) {
      agoraRtcEngine.addPublishStreamUrl("rtmp://ord02.contribute.live-video.net/app/" + webblenLiveStream.twitchStreamKey!, false);
    }
    if (webblenLiveStream.youtubeStreamKey != null && webblenLiveStream.youtubeStreamKey!.isNotEmpty) {
      agoraRtcEngine.addPublishStreamUrl("rtmp://a.rtmp.youtube.com/live2/" + webblenLiveStream.youtubeStreamKey!, false);
    }
    if (webblenLiveStream.fbStreamKey != null && webblenLiveStream.fbStreamKey!.isNotEmpty) {
      LiveTranscoding transcoding = _agoraLiveStreamService.configureTranscoding(uid);
      await agoraRtcEngine.setLiveTranscoding(transcoding);
      agoraRtcEngine.addPublishStreamUrl("rtmps://live-api-s.facebook.com:443/rtmp/" + webblenLiveStream.fbStreamKey!, true);
    }
  }

  toggleMute() {
    muted = !muted;
    notifyListeners();
    agoraRtcEngine.muteLocalAudioStream(muted);
  }

  switchCamera() {
    agoraRtcEngine.switchCamera();
  }

  toggleEndingStream() {
    endingStream = !endingStream;
    notifyListeners();
  }

  displayGifters() async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      customData: webblenLiveStream.id,
      barrierDismissible: true,
      variant: BottomSheetType.displayContentGifters,
    );
    if (sheetResponse != null) {
      //String res = sheetResponse.responseData;
    }
  }

  sendChatMessage(String val) async {
    String text = val.trim();
    if (text.isNotEmpty) {
      WebblenStreamChatMessage message = WebblenStreamChatMessage(
        userImgURL: user.profilePicURL,
        senderUID: user.id,
        username: user.username,
        message: text,
        timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      );
      _liveStreamChatDataService!.sendStreamChatMessage(
          streamID: webblenLiveStream.id, message: message);
    }
    messageFieldController.clear();
    notifyListeners();
  }

  endStream() async {
    await Wakelock.disable();
    try {
      agoraRtcEngine.leaveChannel();
      agoraRtcEngine.destroy();
      _liveStreamDataService.endStream(streamID: webblenLiveStream.id!);
    } catch (e) {}
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _navigationService!.back();
  }

  ///STREAM USER DATA
  @override
  void onData(WebblenLiveStream? data) async {
    if (data != null) {
      if (data.isValid()) {
        if (webblenLiveStream != data) {
          webblenLiveStream = data;

          //setup stream
          if (!liveStreamSetup) {
            //channelName = webblenLiveStream.title;
            bool initializedAgora = await initializeAgoraRtc();
            if (initializedAgora) {
              bool setEventHandlers = await setAgoraRtcEventHandlers();
              if (!setEventHandlers) {
                _snackbarService!.showSnackbar(
                  title: 'Stream Error',
                  message:
                      "There was an unknown error starting your stream. Please try again later.",
                  duration: Duration(seconds: 5),
                );
              }
              liveStreamSetup = true;
            } else {
              _snackbarService!.showSnackbar(
                title: 'Stream Error',
                message:
                    "There was an unknown error starting your stream. Please try again later.",
                duration: Duration(seconds: 5),
              );
            }
          }
          notifyListeners();
          setBusy(false);
        }
      }
    }
  }

  @override
  Stream<WebblenLiveStream> get stream => streamLiveStreamDetails();

  Stream<WebblenLiveStream> streamLiveStreamDetails() async* {
    while (true) {
      WebblenLiveStream val = WebblenLiveStream();
      await Future.delayed(Duration(seconds: 1));
      val = await _liveStreamDataService.getStreamByID(webblenLiveStream.id);
      yield val;
    }
  }
}
