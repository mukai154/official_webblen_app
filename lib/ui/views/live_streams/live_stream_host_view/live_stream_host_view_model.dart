import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_stream_chat_message.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/live_stream_chat_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class LiveStreamHostViewModel extends StreamViewModel<WebblenLiveStream> {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  PlatformDataService? _platformDataService = locator<PlatformDataService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  LiveStreamChatDataService? _liveStreamChatDataService = locator<LiveStreamChatDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///HELPERS
  final messageFieldController = TextEditingController();

  ///STREAM DATA
  WebblenLiveStream webblenLiveStream = WebblenLiveStream();
  bool liveStreamSetup = false;
  String agoraAppID = '60693de17bbe4f2598f9f465d1695de1';
  String channelName = 'test';
  String token = '00660693de17bbe4f2598f9f465d1695de1IADmbMGw/FwWZJQytuhMkL15RIaKYvu/atA5it7ux2ISlAx+f9gAAAAAEADYCUcog3taYAEAAQCDe1pg';
  late RtcEngine agoraRtcEngine;
  bool muted = false;
  bool isInAgoraChannel = true;
  bool isRecording = false;
  bool endingStream = false;
  List users = <int>[];

  ///CHAT
  int startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  ///GIFTING ANIMATION
  AnimationController? giftAnimationController;
  Animation? giftAnimation;

  initialize(String id) async {
    setBusy(true);


    //get stream data
    if (id.isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Stream Error',
        message: "There was an unknown error starting your stream. Please try again later.",
        duration: Duration(seconds: 5),
      );
      _navigationService!.back();
      return;
    } else {
      webblenLiveStream = await _liveStreamDataService.getStreamByID(id);
      if (!webblenLiveStream.isValid()){
        _snackbarService!.showSnackbar(
          title: 'Stream Error',
          message: "There was an unknown error starting your stream. Please try again later.",
          duration: Duration(seconds: 5),
        );
        _navigationService!.back();
        return;
      }
    }

    //join chat
    _liveStreamChatDataService!.joinChatStream(streamID: webblenLiveStream.id, uid: user.id, isHost: true, username: user.username);
  }

  initializeAgoraRtc() async {
    RtcEngineConfig config = RtcEngineConfig(agoraAppID);

    agoraRtcEngine = await RtcEngine.createWithConfig(config).catchError((e) {
      print(e);
    });

    setAgoraRtcEventHandlers();

    VideoEncoderConfiguration vidConfig = VideoEncoderConfiguration(
      dimensions: VideoDimensions(720, 1280),
      frameRate: VideoFrameRate.Fps30,
      bitrate: 1130,
    );
    await agoraRtcEngine.setVideoEncoderConfiguration(vidConfig);
    await agoraRtcEngine.enableVideo();
    await agoraRtcEngine.enableLocalAudio(true);
    await agoraRtcEngine.startPreview();
    await agoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await agoraRtcEngine.setClientRole(ClientRole.Broadcaster);

    //token = await _liveStreamDataService.generateStreamToken(streamID);
    agoraRtcEngine.joinChannel(token, channelName, null, user.id.hashCode);
    notifyListeners();
  }

  setAgoraRtcEventHandlers() {
    agoraRtcEngine.setEventHandler(RtcEngineEventHandler(error: (code) {
      print(code);
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      //enable wakelock
      print('joinChannelSuccess $channel $uid $elapsed');
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
      _liveStreamChatDataService!.sendStreamChatMessage(streamID: webblenLiveStream.id, message: message);
    }
    messageFieldController.clear();
    notifyListeners();
  }

  endStream() async {
    await Wakelock.disable();
    agoraRtcEngine.leaveChannel();
    agoraRtcEngine.destroy();
    _navigationService!.back();
  }

  ///STREAM USER DATA
  @override
  void onData(WebblenLiveStream? data) async {
    if (data != null) {
      if (webblenLiveStream != data) {
        webblenLiveStream = data;

        //setup stream
        if (!liveStreamSetup) {
          //channelName = webblenLiveStream.title;
          await initializeAgoraRtc();
          bool setEventHandlers = await setAgoraRtcEventHandlers();
          if (!setEventHandlers) {
            _snackbarService!.showSnackbar(
              title: 'Stream Error',
              message: "There was an unknown error starting your stream. Please try again later.",
              duration: Duration(seconds: 5),
            );
          }
          liveStreamSetup = true;
        }

        notifyListeners();
        setBusy(false);
      }
    }
  }

  @override
  Stream<WebblenLiveStream> get stream => streamLiveStreamDetails();

  Stream<WebblenLiveStream> streamLiveStreamDetails() async* {
    while (true) {
      WebblenLiveStream val = WebblenLiveStream();
      if (!webblenLiveStream.isValid()) {
        yield val;
      }
      await Future.delayed(Duration(seconds: 1));
      val = await _liveStreamDataService.getStreamByID(webblenLiveStream.id);
      yield val;
    }
  }

}
