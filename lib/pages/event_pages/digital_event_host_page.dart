import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webblen/firebase/data/chat_data.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/models/event_chat_message.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/events/check_in_count_box.dart';
import 'package:webblen/widgets/events/live_now_box.dart';
import 'package:webblen/widgets/events/viewer_count_box.dart';

class DigitalEventHostPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenEvent event;

  const DigitalEventHostPage({Key key, this.currentUser, this.event}) : super(key: key);

  @override
  _DigitalEventHostPageState createState() => _DigitalEventHostPageState();
}

class _DigitalEventHostPageState extends State<DigitalEventHostPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  String agoraAppID = 'f10ecda2344b4c039df6d33953a3f598';
  RtcEngine agoraRtcEngine;
  static final _users = <int>[];
  bool muted = false;
  bool isInAgoraChannel = true;
  bool isRecording = false;
  var tryingToEnd = false;
  bool isLoading = true;
  bool micEnabled = false;
  bool cameraEnabled = false;
//  bool recording = false;
//  bool finishedRecording = false;
//  bool uploadingFiles = false;
//  String uploadStatus;
//  FlutterAudioRecorder audioRecorder;
//  var audioRecording;
//  File vidFile;
//  File audFile;
//  String vidFilePath;
//  String audFilePath;
//  LocalFileSystem localFileSystem = LocalFileSystem();
//  Directory tempDirectory;

  final messageFieldController = TextEditingController();
  ScrollController chatViewController = ScrollController();
  int startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  //Gift Animation
  AnimationController giftAnimationController;
  Animation giftAnimation;

//  ///**** RECORDING, VIDEO UPLOAD, AUDIO UPLOAD
//
//  requestRecordingStart() {
//    if (finishedRecording) {
//      ShowAlertDialogService().showDetailedConfirmationDialog(
//        context,
//        "Re-Record Stream?",
//        "Previous Recording Will Be Discarded",
//        "Record",
//        () {
//          Navigator.of(context).pop();
//          startScreenAndAudioRecord();
//        },
//        () => Navigator.of(context).pop(),
//      );
//    } else {
//      ShowAlertDialogService().showDetailedConfirmationDialog(
//        context,
//        "Record Stream?",
//        "Recorded Streams Are Publicly Availble for 3 Days",
//        "Record",
//        () {
//          Navigator.of(context).pop();
//          startScreenAndAudioRecord();
//        },
//        () => Navigator.of(context).pop(),
//      );
//    }
//  }
//
//  startScreenAndAudioRecord() async {
//    tempDirectory = await getTemporaryDirectory();
//
//    ///RECORD SCREEN
//    await FlutterScreenRecording.startRecordScreen("${widget.event.id} + ${DateTime.now().millisecondsSinceEpoch.toString()}");
//
//    ///RECORD AUDIO
//    audFilePath = tempDirectory.path + "/${DateTime.now().millisecondsSinceEpoch.toString()}audio_rec.wav";
//    audioRecorder = FlutterAudioRecorder(audFilePath, audioFormat: AudioFormat.WAV);
//    await audioRecorder.initialized.catchError((e) => print(e));
//    await audioRecorder.start().catchError((e) => print(e));
//    audioRecording = await audioRecorder.current(channel: 1);
//    if (audioRecorder.recording.status == RecordingStatus.Recording) {
//      recording = true;
//      setState(() {});
//    } else {
//      ShowAlertDialogService().showFailureDialog(context, "Recording Error", "There's An Issue Recording Your Audio. Please Enable Audio Recording");
//    }
//  }
//
//  stopScreenAndAudioRecord() async {
//    vidFilePath = await FlutterScreenRecording.stopRecordScreen;
//    var audResult = await audioRecorder.stop();
//    audFilePath = audResult.path;
//    recording = false;
//    finishedRecording = true;
//    setState(() {});
//  }
//
//  uploadRecordings() async {
//    uploadingFiles = true;
//    setState(() {});
//    uploadStatus = "Compressing Video...";
//    setState(() {});
//    MediaInfo compressedVid = await VideoCompress.compressVideo(
////      vidFilePath,
////      quality: VideoQuality.MediumQuality,
////      deleteOrigin: false,
////    );
//    vidFile = localFileSystem.file(compressedVid.path);
//    audFile = localFileSystem.file(audFilePath);
//    await uploadFile("stream_video", vidFile, "${widget.event.id}.mp4");
//    uploadStatus = "Preparing Audio";
//    setState(() {});
//    await uploadFile("stream_audio", audFile, "${widget.event.id}.wav");
//    await EventDataService().setReviewStatus(widget.event.id, widget.currentUser.uid, widget.event.nearbyZipcodes);
//    uploadStatus = "Upload Complete!";
//    uploadingFiles = false;
//    tryingToEnd = true;
//    setState(() {});
//  }
//
//  Future<String> uploadFile(String bucketName, File file, String fileName) async {
//    String downloadUrl;
//    StorageReference storageReference = FirebaseStorage.instance.ref();
//    StorageReference ref = storageReference.child(bucketName).child(widget.currentUser.uid).child(fileName);
//    StorageUploadTask uploadTask = ref.putFile(
//      file,
//      StorageMetadata(
//        contentType: bucketName == "stream_video" ? 'video/mp4' : 'audio/wav',
//      ),
//    );
//    uploadTask.events.forEach((event) {
//      int percentComplete = ((event.snapshot.bytesTransferred / event.snapshot.totalByteCount) * 100).round();
//      if (bucketName == "stream_video") {
//        if (percentComplete == 100) {
//          uploadStatus = "Finalizing Video...";
//        } else {
//          uploadStatus = "Uploading Video $percentComplete%";
//        }
//        setState(() {});
//      } else {
//        if (percentComplete == 100) {
//          uploadStatus = "Finalizing Audio...";
//        } else {
//          uploadStatus = "Uploading Audio $percentComplete%";
//        }
//        setState(() {});
//      }
//    });
//    await uploadTask.onComplete.catchError((e) => print(e));
//    downloadUrl = await ref.getDownloadURL() as String;
//    return downloadUrl;
//  }
//
//  uploadFilesAndClose() async {
//    uploadingFiles = true;
//    setState(() {});
//    print('uploading files...');
//    MediaInfo mediaInfo = await VideoCompress.compressVideo(
//      vidFilePath,
//      quality: VideoQuality.MediumQuality,
//      deleteOrigin: false, // It's false by default
//    );
//    vidFilePath = mediaInfo.path;
//    vidFile = localFileSystem.file(vidFilePath);
//    audFile = localFileSystem.file(audFilePath);
//    print(vidFile);
//    print(audFile);
//    print("uploading video...");
//    String vidURL = await FileUploader().uploadStreamVideo(vidFile, widget.currentUser.uid, "${widget.event.id}.mp4");
//    print(vidURL);
//    print("uploading audio...");
//    String audURL = await FileUploader().uploadStreamAudio(audFile, widget.currentUser.uid, "${widget.event.id}.wav");
//    print(audURL);
//    print("Upload Complete");
//    uploadingFiles = false;
//    tryingToEnd = true;
//    setState(() {});
//  }

  initialize() async {
    await initializeAgoraRtc();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(MediaQuery.of(context).size.height.round(), MediaQuery.of(context).size.width.round());
    configuration.frameRate = VideoFrameRate.Fps30;
    await agoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await agoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await agoraRtcEngine.setClientRole(ClientRole.Broadcaster);
    await agoraRtcEngine.joinChannel(null, widget.event.id, null, 0).catchError((e) {
      print(e);
    });
    checkPermissions();
    setAgoraRtcEventHandlers();
    isLoading = false;
    setState(() {});
  }

  checkPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;
    if (cameraStatus.isUndetermined || cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      await Permission.camera.request();
    }
    if (micStatus.isUndetermined || micStatus.isDenied || micStatus.isPermanentlyDenied) {
      await Permission.microphone.request();
    }
    if (cameraStatus.isGranted) {
      cameraEnabled = true;
      setState(() {});
    }
    if (micStatus.isGranted) {
      micEnabled = true;
      setState(() {});
    }
  }

  /// Create agora sdk instance and initialize
  initializeAgoraRtc() async {
    agoraRtcEngine = await RtcEngine.create(agoraAppID);
    await agoraRtcEngine.enableVideo();
    await agoraRtcEngine.enableLocalAudio(true);
  }

  setAgoraRtcEventHandlers() {
    agoraRtcEngine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        print('Error: $code');
      });
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      EventDataService().createActiveLiveStream(
        widget.event.id,
        widget.currentUser.uid,
        widget.currentUser.username,
        widget.currentUser.profile_pic,
        widget.event.nearbyZipcodes,
        DateTime.now().millisecondsSinceEpoch,
      );
      EventDataService().notifyFollowersStreamIsLive(widget.event.id, widget.currentUser.uid);

      await Wakelock.enable();
    }, leaveChannel: (stats) {
      setState(() {
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        print('video started');
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();

    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
    }
    return Container();
  }

  void toggleMute() {
    setState(() {
      muted = !muted;
    });
    agoraRtcEngine.muteLocalAudioStream(muted);
  }

  void switchCamera() {
    agoraRtcEngine.switchCamera();
  }

  Future<bool> _willPopCallback() async {
    setState(() {
      tryingToEnd = !tryingToEnd;
    });
    return false; // return true if the route to be popped
  }

  Widget _endCall() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  tryingToEnd = true;
                });
              },
              child: Text(
                'END',
                style: TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget donatorContainer(String uid, String username, String userImgURL, double totalGiftAmount) {
    return GestureDetector(
      onTap: null,
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: userImgURL,
            imageBuilder: (context, imageProvider) => Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '@$username',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 15,
                width: 15,
                child: Image.asset(
                  'assets/images/webblen_coin.png',
                ),
              ),
              SizedBox(width: 4),
              Text(
                totalGiftAmount.toStringAsFixed(2),
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget streamHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Text(
                    widget.event.title,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    tryingToEnd = true;
                    setState(() {});
                  },
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.white60,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                LiveNowBox(),
                SizedBox(width: 8.0),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("event_chats").doc(widget.event.id).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) return Container();
                    var streamData = snapshot.data.data();
                    List activeMembers = streamData['activeMembers'] == null ? [widget.currentUser.uid] : streamData['activeMembers'];
                    return ViewerCountBox(viewCount: activeMembers.length);
                  },
                ),
                SizedBox(width: 8.0),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("events").doc(widget.event.id).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) return Container();
                    var eventData = snapshot.data.data();
                    List attendees = eventData['d']['attendees'];
                    return CheckInCountBox(checkInCount: attendees.length);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          cameraEnabled
              ? Container()
              : GestureDetector(
                  onTap: () {
                    openAppSettings();
                  },
                  child: Container(
                    child: Text(
                      "Please Enable Your Camera",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          SizedBox(height: 8.0),
          micEnabled
              ? Container()
              : GestureDetector(
                  onTap: () {
                    openAppSettings();
                  },
                  child: Container(
                    child: Text(
                      "Please Enable Your Microphone",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
//          Row(
//            children: [
//              GestureDetector(
//                onTap: recording ? () => stopScreenAndAudioRecord() : () => requestRecordingStart(),
//                child: Container(
//                  height: 24,
//                  width: 30,
//                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
//                  decoration: BoxDecoration(
//                    color: finishedRecording
//                        ? CustomColors.darkMountainGreen
//                        : recording
//                            ? CustomColors.webblenRed
//                            : Colors.black38,
//                    borderRadius: BorderRadius.all(Radius.circular(8)),
//                  ),
//                  child: Icon(
//                    finishedRecording
//                        ? FontAwesomeIcons.solidFileVideo
//                        : recording
//                            ? FontAwesomeIcons.solidDotCircle
//                            : FontAwesomeIcons.video,
//                    color: Colors.white,
//                    size: 11.0,
//                  ),
//                ),
//              ),
//            ],
//          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    if (!isInAgoraChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            new Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                height: 40,
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  maxLengthEnforced: true,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (val) {
                    String text = val.trim();
                    if (text.isNotEmpty) {
                      EventChatMessage message = EventChatMessage(
                        userImgURL: widget.currentUser.profile_pic,
                        senderUID: widget.currentUser.uid,
                        username: widget.currentUser.username,
                        message: text,
                        timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
                      );
                      ChatDataService().sendEventChatMessage(widget.event.id, message);
                    }
                    messageFieldController.clear();
                    setState(() {});
                  },
                  style: TextStyle(color: Colors.white),
                  controller: messageFieldController,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(150),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Comment',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black87,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            height: 400,
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance.collection("gift_donations").doc(widget.event.id).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (!snapshot.hasData || !snapshot.data.exists)
                                  return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Container(
                                          child: Text(
                                            'Top Gifters',
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                "Stream Has Not Received Gifts",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white60,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                Map<String, dynamic> donatorsMap = snapshot.data.data()['donators'] == null ? {} : snapshot.data.data()['donators'];
                                List donators = donatorsMap.values.toList(growable: true);
                                print(donators.length);
                                if (donators.length > 1) {
                                  donators.sort((a, b) => b['totalGiftAmount'].compareTo(a['totalGiftAmount']));
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Text(
                                      'Top Gifters',
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Container(
                                      height: 200,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              donators.length < 1
                                                  ? Container(width: 100)
                                                  : Container(
                                                      width: 100,
                                                      child: donatorContainer(
                                                        donators[0]['uid'],
                                                        donators[0]['username'],
                                                        donators[0]['userImgURL'],
                                                        donators[0]['totalGiftAmount'],
                                                      ),
                                                    ),
                                              donators.length < 2
                                                  ? Container(width: 100)
                                                  : Container(
                                                      width: 100,
                                                      child: donatorContainer(
                                                        donators[1]['uid'],
                                                        donators[1]['username'],
                                                        donators[1]['userImgURL'],
                                                        donators[1]['totalGiftAmount'],
                                                      ),
                                                    ),
                                              donators.length < 3
                                                  ? Container(width: 100)
                                                  : Container(
                                                      width: 100,
                                                      child: donatorContainer(
                                                        donators[2]['uid'],
                                                        donators[2]['username'],
                                                        donators[2]['userImgURL'],
                                                        donators[2]['totalGiftAmount'],
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              donators.length < 4
                                                  ? Container(width: 100)
                                                  : Container(
                                                      width: 100,
                                                      child: donatorContainer(
                                                        donators[3]['uid'],
                                                        donators[3]['username'],
                                                        donators[3]['userImgURL'],
                                                        donators[3]['totalGiftAmount'],
                                                      ),
                                                    ),
                                              donators.length < 5
                                                  ? Container(width: 100)
                                                  : Container(
                                                      width: 100,
                                                      child: donatorContainer(
                                                        donators[4]['uid'],
                                                        donators[4]['username'],
                                                        donators[4]['userImgURL'],
                                                        donators[4]['totalGiftAmount'],
                                                      ),
                                                    ),
                                              donators.length < 6
                                                  ? Container(width: 100)
                                                  : Container(
                                                      width: 100,
                                                      child: donatorContainer(
                                                        donators[5]['uid'],
                                                        donators[5]['username'],
                                                        donators[5]['userImgURL'],
                                                        donators[5]['totalGiftAmount'],
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "Total: ",
                                                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 15,
                                              width: 15,
                                              child: Image.asset(
                                                'assets/images/webblen_coin.png',
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data.data()['giftPool'].toStringAsFixed(2),
                                                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 0.0,
                color: Colors.black26,
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: toggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 0.0,
                color: Colors.black26,
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: switchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 0.0,
                color: Colors.black26,
                padding: const EdgeInsets.all(12.0),
              ),
            )
          ]),
        ),
      ),
    );
  }

//  Widget upload() {
//    return Container(
//      color: Colors.black.withOpacity(0.5),
//      child: Stack(
//        children: <Widget>[
//          Align(
//            alignment: Alignment.center,
//            child: Padding(
//              padding: const EdgeInsets.all(30.0),
//              child: Text(
//                uploadStatus,
//                textAlign: TextAlign.center,
//                style: TextStyle(color: Colors.white, fontSize: 20),
//              ),
//            ),
//          ),
//          Container(
//            alignment: Alignment.bottomCenter,
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceAround,
//              children: <Widget>[
//                Expanded(
//                  child: Padding(
//                    padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
//                    child: RaisedButton(
//                      child: Padding(
//                        padding: const EdgeInsets.symmetric(vertical: 15),
//                        child: Text(
//                          'Cancel',
//                          style: TextStyle(color: Colors.white),
//                        ),
//                      ),
//                      elevation: 2.0,
//                      color: Colors.grey,
//                      onPressed: () {
//                        setState(() {
//                          uploadingFiles = false;
//                        });
//                      },
//                    ),
//                  ),
//                )
//              ],
//            ),
//          )
//        ],
//      ),
//    );
//  }

  Widget endLive() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Are you sure you want to end your live stream?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0, top: 8.0, bottom: 8.0),
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'End Stream',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.red,
                      onPressed: () async {
                        await Wakelock.disable();
                        agoraRtcEngine.leaveChannel();
                        agoraRtcEngine.destroy();
                        EventDataService().endActiveStream(widget.event.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          tryingToEnd = false;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  scrollToChatMessage() async {
    if (chatViewController.hasClients && chatViewController.position.pixels == chatViewController.position.maxScrollExtent) {
      await Future.delayed(Duration(milliseconds: 500));
      if (chatViewController.hasClients) {
        chatViewController.jumpTo(chatViewController.position.maxScrollExtent);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
    giftAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3500),
    );
    giftAnimation = CurvedAnimation(parent: giftAnimationController, curve: Curves.elasticInOut);
    giftAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        giftAnimationController.reverse();
      }
    });
    ChatDataService().joinChatStream(
      widget.event.id,
      widget.currentUser.uid,
      true,
      widget.currentUser.username,
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    agoraRtcEngine.leaveChannel();
    agoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToChatMessage());

    Widget messageList() {
      return Container(
        margin: EdgeInsets.only(bottom: 50),
        alignment: Alignment.bottomLeft,
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("event_chats")
                  .doc(widget.event.id)
                  .collection("messages")
                  .where('timePostedInMilliseconds', isGreaterThan: startChatAfterTimeInMilliseconds)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) return Container();
                return ListView.builder(
                  controller: chatViewController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    scrollToChatMessage();
                    String username = '@' + snapshot.data.docs[index].data()['username'];
                    String message = snapshot.data.docs[index].data()['message'];
                    String userImgURL = snapshot.data.docs[index].data()['userImgURL'];
                    return username == '@system'
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.only(left: 8.0),
                            child: Fonts().textW700(
                              '$message',
                              14.0,
                              Colors.white54,
                              TextAlign.left,
                            ))
                        : Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            //width: MediaQuery.of(context).size.width * 0.7,
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4.0),
                                    CachedNetworkImage(
                                      imageUrl: userImgURL,
                                      imageBuilder: (context, imageProvider) => Container(
                                        width: 32.0,
                                        height: 32.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        username,
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        message,
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    Widget giftsAndDonationsStream() {
      return Container(
        margin: EdgeInsets.only(bottom: 50),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("gift_donations")
                  .doc(widget.event.id)
                  .collection("gift_donations")
                  .where('timePostedInMilliseconds', isGreaterThan: DateTime.now().millisecondsSinceEpoch - 30000)
                  .orderBy("timePostedInMilliseconds", descending: false)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) return Container();
                return ListView.builder(
                  //controller: chatViewController,
                  itemCount: 1, //snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    String senderUsername = snapshot.data.docs.last.data()['senderUsername'];
                    int giftID = snapshot.data.docs.last.data()['giftID'];
                    String giftAmount = snapshot.data.docs.last.data()['giftAmount'].toStringAsFixed(2);
                    giftAnimationController.forward();
                    return FadeTransition(
                      opacity: giftAnimation,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(
                                giftID == 1
                                    ? 'assets/images/heart_icon.png'
                                    : giftID == 2
                                        ? 'assets/images/double_heart_icon.png'
                                        : giftID == 3
                                            ? 'assets/images/confetti_icon.png'
                                            : giftID == 4
                                                ? 'assets/images/dj_icon.png'
                                                : giftID == 5
                                                    ? 'assets/images/wolf_icon.png'
                                                    : giftID == 6
                                                        ? 'assets/images/eagle_icon.png'
                                                        : giftID == 7
                                                            ? 'assets/images/heart_fire_icon.png'
                                                            : 'assets/images/webblen_coin.png',
                              ),
                            ),
                            Fonts().textW700(
                              '$senderUsername gifted $giftAmount Webblen',
                              25.0,
                              Colors.white,
                              TextAlign.left,
                            ),
                          ],
                        ),
                        //color: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: Stack(
                children: <Widget>[
                  isLoading ? Container() : _viewRows(), // Video Widget
                  if (tryingToEnd == false && !isLoading) streamHeader(),
                  if (tryingToEnd == false && !isLoading) giftsAndDonationsStream(),
                  if (tryingToEnd == false && !isLoading) messageList(),
                  if (tryingToEnd == false && !isLoading) _bottomBar(), // send message
                  if (tryingToEnd == true && !isLoading) endLive(), //
                  //if (uploadingFiles && !isLoading) upload(), // view message
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: _willPopCallback,
    );
  }
}
