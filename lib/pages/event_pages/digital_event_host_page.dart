import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webblen/firebase/data/chat_data.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/models/event_chat_message.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/check_in_count_box.dart';
import 'package:webblen/widgets/events/live_now_box.dart';
import 'package:webblen/widgets/events/viewer_count_box.dart';

class DigitalEventHostPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final WebblenUser currentUser;
  final WebblenEvent event;

  /// Creates a call page with given channel name.
  const DigitalEventHostPage({Key key, this.currentUser, this.event}) : super(key: key);

  @override
  _DigitalEventHostPageState createState() => _DigitalEventHostPageState();
}

class _DigitalEventHostPageState extends State<DigitalEventHostPage> {
  String agoraAppID = 'f10ecda2344b4c039df6d33953a3f598';
  static final _users = <int>[];
  bool muted = false;
  bool isLoggedIntoAgoraRtm = true;
  bool isInAgoraChannel = true;
  int audienceSize = 0;
  var tryingToEnd = false;

  final messageFieldController = TextEditingController();
  ScrollController chatViewController = ScrollController();
  int startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  AgoraRtmClient agoraRtmClient;
  AgoraRtmChannel agoraRtmChannel;

  initialize() async {
    await initializeAgoraRtc();
    setAgoraRtcEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    configuration.frameRate = 30;
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.event.id, widget.currentUser.uid, 0);
    await initializeAgoraRtm();
    setAgoraRtmEventHandlers();
  }

  /// Create agora sdk instance and initialize
  initializeAgoraRtc() async {
    await AgoraRtcEngine.create(agoraAppID);
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(ClientRole.Broadcaster);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.enableLocalAudio(true);
  }

  initializeAgoraRtm() async {
    agoraRtmClient = await AgoraRtmClient.createInstance(agoraAppID);
    await agoraRtmClient.login(null, widget.event.id);
    agoraRtmChannel = await agoraRtmClient.createChannel(widget.event.id);
    await agoraRtmChannel.join();
  }

  setAgoraRtcEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess = (String channel, int uid, int elapsed) async {
      EventDataService().createActiveLiveStream(
        widget.event.id,
        widget.currentUser.uid,
        widget.currentUser.username,
        widget.currentUser.profile_pic,
        DateTime.now().millisecondsSinceEpoch,
      );
      await Wakelock.enable();
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        _users.remove(uid);
      });
    };
  }

  setAgoraRtmEventHandlers() {
    agoraRtmClient.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        agoraRtmClient.logout();
        isLoggedIntoAgoraRtm = false;
        setState(() {});
      }
    };
    agoraRtmChannel.onMemberCountUpdated = (int res) {
      audienceSize = res;
      setState(() {});
    };
  }

  void _logout() async {
    try {
      await agoraRtmClient.logout();
      //_log(info:'Logout success.',type: 'logout');
    } catch (errorCode) {
      //_log(info: 'Logout error: ' + errorCode.toString(), type: 'error');
    }
  }

  void _leaveChannel() async {
    try {
      await agoraRtmChannel.leave();
      //_log(info: 'Leave channel success.',type: 'leave');
      agoraRtmClient.releaseChannel(agoraRtmChannel.channelId);
      messageFieldController.text = null;
    } catch (errorCode) {
      // _log(info: 'Leave channel error: ' + errorCode.toString(),type: 'error');
    }
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: ClipRRect(child: view));
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
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void switchCamera() {
    AgoraRtcEngine.switchCamera();
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

  Widget streamHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
      child: Column(
        children: [
          Container(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  context: context,
                  text: widget.event.title,
                  textColor: Colors.white,
                  textAlign: TextAlign.left,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tryingToEnd = true;
                    });
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
                ViewerCountBox(viewCount: audienceSize),
                SizedBox(width: 8.0),
                StreamBuilder(
                  stream: Firestore.instance.collection("events").document(widget.event.id).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    var eventData = snapshot.data;
                    List attendees = eventData['d']['attendees'];
                    return CheckInCountBox(checkInCount: attendees.length);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    if (!isLoggedIntoAgoraRtm || !isInAgoraChannel) {
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
                onPressed: () => print('clicked gift'),
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
                        _logout();
                        _leaveChannel();
                        AgoraRtcEngine.leaveChannel();
                        AgoraRtcEngine.destroy();
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
    if (chatViewController.position.pixels == chatViewController.position.maxScrollExtent) {
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
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
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
              stream: Firestore.instance
                  .collection("event_chats")
                  .document(widget.event.id)
                  .collection("messages")
                  .where('timePostedInMilliseconds', isGreaterThan: startChatAfterTimeInMilliseconds)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.documents.isEmpty) return Container();
                return ListView.builder(
                  controller: chatViewController,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    scrollToChatMessage();
                    String username = '@' + snapshot.data.documents[index].data['username'];
                    String message = snapshot.data.documents[index].data['message'];
                    String userImgURL = snapshot.data.documents[index].data['userImgURL'];
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

    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: Stack(
                children: <Widget>[
                  _viewRows(), // Video Widget
                  if (tryingToEnd == false) streamHeader(),
                  if (tryingToEnd == false) messageList(),
                  if (tryingToEnd == false) _bottomBar(), // send message
                  if (tryingToEnd == true) endLive(), // view message
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
