import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_stream_chat_message.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/agora/agora_live_stream_service.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/live_stream_chat_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class LiveStreamViewerViewModel extends StreamViewModel<WebblenLiveStream> {
  NavigationService? _navigationService = locator<NavigationService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  LiveStreamChatDataService? _liveStreamChatDataService = locator<LiveStreamChatDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  UserDataService _userDataService = locator<UserDataService>();
  AgoraLiveStreamService _agoraLiveStreamService = locator<AgoraLiveStreamService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///HELPERS
  final messageFieldController = TextEditingController();

  ///STREAM DATA
  bool isLive = false;
  bool updatingCheckIn = false;
  bool checkedIn = false;
  String? streamID;
  WebblenLiveStream webblenLiveStream = WebblenLiveStream();
  bool liveStreamSetup = false;
  String agoraAppID = '60693de17bbe4f2598f9f465d1695de1';
  late RtcEngine agoraRtcEngine;
  bool muted = false;
  bool isInAgoraChannel = true;
  bool isRecording = false;
  bool endingStream = false;
  bool showWaitingRoom = true;
  List users = <int>[];

  ///HOST DATA
  String? hostUserName = "";

  ///CHAT
  int startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  ///GIFTING ANIMATION
  AnimationController? giftAnimationController;
  Animation? giftAnimation;

  initialize(String id) async {
    setBusy(true);
    //Set Device Orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    //get stream data
    if (id.isEmpty) {
      _snackbarService!.showSnackbar(
        title: 'Stream Error',
        message: "There was an unknown error viewing this stream. Please try again later.",
        duration: Duration(seconds: 5),
      );
      return;
    }

    //get stream
    streamID = id;
    webblenLiveStream = await _liveStreamDataService.getStreamByID(streamID);
    notifyListeners();

    //check if user checked into stream
    if (await _liveStreamDataService.isCheckedIntoThisStream(user: user, streamID: streamID!)) {
      checkedIn = true;
    }

    WebblenUser host = await _userDataService.getWebblenUserByID(webblenLiveStream.hostID);
    if (host.isValid()) {
      hostUserName = host.username;
    }

    //join chat
    _liveStreamChatDataService!.joinChatStream(streamID: streamID, uid: user.id, isHost: false, username: user.username);

    setBusy(false);
  }

  Future<bool> initializeAgoraRtc() async {
    RtcEngineConfig config = RtcEngineConfig(agoraAppID);

    agoraRtcEngine = await RtcEngine.createWithConfig(config).catchError((e) {
      print(e);
    });

    notifyListeners();

    await setAgoraRtcEventHandlers();
    VideoEncoderConfiguration vidConfig = _agoraLiveStreamService.getVideoConfig();

    await agoraRtcEngine.setVideoEncoderConfiguration(vidConfig);
    await agoraRtcEngine.enableVideo();
    await agoraRtcEngine.enableLocalAudio(true);
    await agoraRtcEngine.startPreview();
    await agoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await agoraRtcEngine.setClientRole(ClientRole.Audience);

    String? token = await _agoraLiveStreamService.generateStreamToken(channelName: webblenLiveStream.id!, uid: user.id!, role: "SUBSCRIBER");
    if (token != null) {
      await agoraRtcEngine.joinChannelWithUserAccount(token, webblenLiveStream.id!, user.id!);
    }

    notifyListeners();
    return true;
  }

  Future<bool> setAgoraRtcEventHandlers() async {
    String? error;
    agoraRtcEngine.setEventHandler(RtcEngineEventHandler(error: (code) {
      print(code);
      error = code.toString();
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
      showWaitingRoom = false;
      users.add(uid);
      notifyListeners();
    }, userOffline: (uid, elapsed) {
      //leave channel
      users.remove(uid);
      notifyListeners();
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      //video started
      if (webblenLiveStream.activeViewers == null || !webblenLiveStream.activeViewers!.contains(user.id!)) {
        _liveStreamDataService.addToActiveViewers(uid: user.id!, streamID: webblenLiveStream.id!);
      }
      showWaitingRoom = false;
      notifyListeners();
    }));
    if (error != null) {
      return false;
    }
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

  switchToLandScape() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    await Future.delayed(Duration(milliseconds: 500));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  giftWBLN() async {
    await customBottomSheetService.showGiftWebblenBottomSheet(contentID: webblenLiveStream.id!, hostID: webblenLiveStream.hostID!);
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
    if (webblenLiveStream.activeViewers != null && webblenLiveStream.activeViewers!.contains(user.id!)) {
      _liveStreamDataService.removeFromActiveViewers(uid: user.id!, streamID: webblenLiveStream.id!);
    }
    await Wakelock.disable();
    agoraRtcEngine.leaveChannel();
    agoraRtcEngine.destroy();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _navigationService!.back();
  }

  streamIsLive() {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = webblenLiveStream.startDateTimeInMilliseconds!;
    int? eventEndDateInMilli = webblenLiveStream.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli!) {
      isLive = true;
    } else {
      isLive = false;
    }
    notifyListeners();
  }

  checkInCheckoutOfStream() async {
    streamIsLive();
    if (isLive) {
      updatingCheckIn = true;
      notifyListeners();
      if (checkedIn) {
        bool confirmedCheckout = await customBottomSheetService.showCheckoutEventDialog();
        if (confirmedCheckout) {
          bool checkedOut = await _liveStreamDataService.checkOutOfStream(user: user, streamID: webblenLiveStream.id!);
          if (checkedOut) {
            checkedIn = false;
          }
        }
      } else {
        checkedIn = await _liveStreamDataService.checkIntoStream(user: user, streamID: webblenLiveStream.id!);
      }
      updatingCheckIn = false;
      notifyListeners();
      HapticFeedback.lightImpact();
    } else {
      _customDialogService.showErrorDialog(description: "You can no longer check in/out of this stream");
    }
  }

  scrollToChatMessage(ScrollController scrollController) async {
    if (scrollController.hasClients && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      await Future.delayed(Duration(milliseconds: 500));
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    }
  }

  ///STREAM LIVE STREAM DATA
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
              liveStreamSetup = true;
            } else {
              _snackbarService!.showSnackbar(
                title: 'Stream Error',
                message: "There was an unknown error viewing this stream. Please try again later.",
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
