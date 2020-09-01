import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase/data/chat_data.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/event_chat_message.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_home/check_in_floating_action.dart';

enum BottomSheetMode {
  rewards,
  refill,
}

class DigitalEventPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  // final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  final WebblenUser currentUser;
  final WebblenEvent event;

  /// Creates a call page with given channel name.
  const DigitalEventPage({Key key, this.currentUser, this.event, this.role}) : super(key: key);

  @override
  _DigitalEventPageState createState() => _DigitalEventPageState();
}

class _DigitalEventPageState extends State<DigitalEventPage> {
  bool isLoading = true;
  bool isCommenting = false;
  WebblenUser host;
  String agoraAppID;
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  String newMessage;
  GlobalKey messageFieldKey = GlobalKey<FormState>();
  TextEditingController chatController = TextEditingController();
  ScrollController chatViewController = ScrollController();
  int startChatAfterTimeInMilliseconds;
  BottomSheetMode bottomSheetMode = BottomSheetMode.rewards;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    chatViewController.dispose();
    chatController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    setState(() {});
    initialize();
    ChatDataService().joinChatStream(
      widget.event.id,
      widget.currentUser.uid,
      widget.role == ClientRole.Broadcaster ? true : false,
      widget.currentUser.username,
    );
  }

  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
    isCommenting = false;
    setState(() {});
  }

  //VIDEO STREAM WIDGETS
  Widget commentField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), color: Colors.black45),
      child: Form(
        key: messageFieldKey,
        child: TextFormField(
          controller: chatController,
          minLines: 1,
          maxLines: 5,
          maxLengthEnforced: true,
          onTap: () {
            isCommenting = true;
            setState(() {});
          },
          cursorColor: Colors.white,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (val) {
            String text = val.trim();
            if (text.isNotEmpty) {
              EventChatMessage message = EventChatMessage(
                senderUID: widget.currentUser.uid,
                username: widget.currentUser.username,
                message: text,
                timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
              );
              ChatDataService().sendEventChatMessage(widget.event.id, message);
            }
            chatController.clear();
            isCommenting = false;
            setState(() {});
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(75),
          ],
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Comment",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Future<void> initialize() async {
    agoraAppID = 'f10ecda2344b4c039df6d33953a3f598';
    host = await WebblenUserData().getUserByID(widget.event.authorID);
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(1920, 1080);
    configuration.frameRate = 25;
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.event.id, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    print(widget.role);
    await AgoraRtcEngine.create(agoraAppID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
    if (widget.role == ClientRole.Audience) {
      await AgoraRtcEngine.joinChannel(null, widget.event.id, 'testInfo', 0);
    }
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        if (widget.currentUser.uid == widget.event.authorID) {
          final info = '@${widget.currentUser.username} has started streaming!';
          _infoStrings.add(info);
        }
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
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
      case 3:
        return Container(
            child: Column(
          children: <Widget>[_expandedVideoRow(views.sublist(0, 2)), _expandedVideoRow(views.sublist(2, 3))],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[_expandedVideoRow(views.sublist(0, 2)), _expandedVideoRow(views.sublist(2, 4))],
        ));
      default:
    }
    return Container();
  }

  Widget _awardIcon(int awardNum) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          child: Image.asset(
            awardNum == 1
                ? 'assets/images/heart_icon.png'
                : awardNum == 2
                    ? 'assets/images/double_heart_icon.png'
                    : awardNum == 3
                        ? 'assets/images/confetti_icon.png'
                        : awardNum == 4
                            ? 'assets/images/dj_icon.png'
                            : awardNum == 5
                                ? 'assets/images/wolf_icon.png'
                                : awardNum == 6
                                    ? 'assets/images/eagle_icon.png'
                                    : awardNum == 7 ? 'assets/images/heart_fire_icon.png' : 'assets/images/webblen_coin.png',
          ),
        ),
        SizedBox(height: 4),
        Text(
          awardNum == 1
              ? 'Love'
              : awardNum == 2
                  ? 'More Love'
                  : awardNum == 3
                      ? 'Confetti'
                      : awardNum == 4 ? 'Party' : awardNum == 5 ? 'Wolf' : awardNum == 6 ? 'Eagle' : awardNum == 7 ? 'Much Love' : 'Webblen',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              awardNum == 1
                  ? '0.10'
                  : awardNum == 2
                      ? '0.50'
                      : awardNum == 3 ? '5' : awardNum == 4 ? '25' : awardNum == 5 ? '50' : awardNum == 6 ? '100' : awardNum == 7 ? '500' : '1',
              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
            ),
            SizedBox(width: 4),
            Container(
              height: 15,
              width: 15,
              child: Image.asset(
                'assets/images/webblen_coin.png',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _gridItem(int itemNum) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 20,
                width: 20,
                child: Image.asset(
                  'assets/images/webblen_coin.png',
                ),
              ),
              SizedBox(width: 2),
              Text(
                itemNum == 1 ? '1' : itemNum == 2 ? '5' : itemNum == 3 ? '25' : itemNum == 4 ? '50' : '100',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            itemNum == 1 ? '\$0.99' : itemNum == 2 ? '\$4.99' : itemNum == 3 ? '\$24.99' : itemNum == 4 ? '\$49.99' : '\$99.99',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w300,
            ),
          )
        ],
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            commentField(),
            Column(
              children: [
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    height: 35,
                    width: 35,
                    child: Image.asset(
                      'assets/images/gift_box.png',
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black87,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: 402,
                              child: bottomSheetMode == BottomSheetMode.rewards
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Awards',
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _awardIcon(1),
                                            _awardIcon(2),
                                            _awardIcon(3),
                                            _awardIcon(4),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _awardIcon(5),
                                            _awardIcon(6),
                                            _awardIcon(7),
                                            _awardIcon(8),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 15,
                                                    width: 15,
                                                    child: Image.asset(
                                                      'assets/images/webblen_coin.png',
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  StreamBuilder(
                                                    stream: Firestore.instance.collection("webblen_user").document(widget.currentUser.uid).snapshots(),
                                                    builder: (context, userSnapshot) {
                                                      if (!userSnapshot.hasData)
                                                        return Text(
                                                          "Loading...",
                                                        );
                                                      var userData = userSnapshot.data;
                                                      double availablePoints = userData['d']["eventPoints"] * 1.00;
                                                      return Padding(
                                                        padding: EdgeInsets.all(4.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                              availablePoints.toStringAsFixed(2),
                                                              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                child: Text(
                                                  'Get More Webblen',
                                                  style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    bottomSheetMode = BottomSheetMode.refill;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width / 3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 15,
                                                      width: 15,
                                                      child: Image.asset(
                                                        'assets/images/webblen_coin.png',
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    StreamBuilder(
                                                      stream: Firestore.instance.collection("webblen_user").document(widget.currentUser.uid).snapshots(),
                                                      builder: (context, userSnapshot) {
                                                        if (!userSnapshot.hasData)
                                                          return Text(
                                                            "...",
                                                          );
                                                        var userData = userSnapshot.data;
                                                        double availablePoints = userData['d']["eventPoints"] * 1.00;
                                                        return Padding(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Text(
                                                                availablePoints.toStringAsFixed(2),
                                                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width / 3,
                                              child: Text(
                                                'Refill',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width / 3,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: GridView.count(
                                            childAspectRatio: 3 / 2,
                                            shrinkWrap: true,
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 18,
                                            children: [
                                              _gridItem(1),
                                              _gridItem(2),
                                              _gridItem(3),
                                              _gridItem(4),
                                              _gridItem(5),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: GestureDetector(
                                            child: Text(
                                              'Back',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                bottomSheetMode = BottomSheetMode.rewards;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 8),
                CheckInFloatingAction(
                  checkInAvailable: true,
                  isVirtualEventCheckIn: true,
                  checkInAction: didPressCheckIn,
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.white54,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.red : Colors.black26,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.white54,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.black26,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  scrollToChatMessage() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (chatViewController.hasClients) {
      chatViewController.jumpTo(chatViewController.position.maxScrollExtent);
    }
  }

  void didPressCheckIn() {
    List attendees = widget.event.attendees;
    final currentUserUid = widget.currentUser.uid;
    if (!attendees.contains(currentUserUid)) {
      attendees.add(currentUserUid);
    }
    EventDataService().updateEvent(
        WebblenEvent(
          id: widget.event.id,
          authorID: widget.event.authorID,
          hasTickets: widget.event.hasTickets,
          flashEvent: widget.event.flashEvent,
          isDigitalEvent: widget.event.isDigitalEvent,
          digitalEventLink: widget.event.digitalEventLink,
          title: widget.event.title,
          desc: widget.event.desc,
          imageURL: widget.event.imageURL,
          venueName: widget.event.venueName,
          nearbyZipcodes: widget.event.nearbyZipcodes,
          streetAddress: widget.event.streetAddress,
          city: widget.event.city,
          province: widget.event.province,
          lat: widget.event.lat,
          lon: widget.event.lon,
          sharedComs: widget.event.sharedComs,
          tags: widget.event.tags,
          type: widget.event.type,
          category: widget.event.category,
          clicks: widget.event.clicks,
          website: widget.event.website,
          fbUsername: widget.event.fbUsername,
          instaUsername: widget.event.instaUsername,
          checkInRadius: widget.event.checkInRadius,
          estimatedTurnout: widget.event.estimatedTurnout,
          actualTurnout: widget.event.actualTurnout,
          attendees: attendees,
          eventPayout: widget.event.eventPayout,
          recurrence: widget.event.recurrence,
          startDateTimeInMilliseconds: widget.event.startDateTimeInMilliseconds,
          startDate: widget.event.startDate,
          startTime: widget.event.startTime,
          endDate: widget.event.endDate,
          endTime: widget.event.endTime,
          timezone: widget.event.timezone,
          privacy: widget.event.privacy,
          reported: widget.event.reported,
        ),
        widget.event.id);
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToChatMessage());
    Widget eventChat() {
      return StreamBuilder(
        stream: Firestore.instance
            .collection("event_chats")
            .document(widget.event.id)
            .collection("messages")
            .where('timePostedInMilliseconds', isGreaterThan: startChatAfterTimeInMilliseconds - 300000)
            .orderBy("timePostedInMilliseconds", descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data.documents.isEmpty) return Container();
          return ListView.builder(
            controller: chatViewController,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              scrollToChatMessage();
              String username = '@' + snapshot.data.documents[index].data['username'];
              String message = snapshot.data.documents[index].data['message'];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: username == '@system'
                    ? Fonts().textW400(
                        '$message',
                        14.0,
                        username == '@system' ? Colors.white30 : Colors.white,
                        TextAlign.left,
                      )
                    : Fonts().textW700(
                        '$username: $message',
                        14.0,
                        Colors.white,
                        TextAlign.left,
                      ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (isCommenting) {
                                    dismissKeyboard();
                                  } else {
                                    AgoraRtcEngine.leaveChannel();
                                    await ChatDataService().leaveChatStream(
                                      widget.event.id,
                                      widget.currentUser.uid,
                                      widget.role == ClientRole.Broadcaster ? true : false,
                                      widget.currentUser.username,
                                    );
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: isCommenting
                                    ? CustomText(
                                        context: context,
                                        text: "Cancel",
                                        textColor: Colors.white60,
                                        textAlign: TextAlign.right,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                      )
                                    : Icon(
                                        FontAwesomeIcons.times,
                                        color: Colors.white60,
                                        size: 24.0,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 20,
                          child: Row(
                            children: [
                              CustomText(
                                context: context,
                                text: "Hosted by: ",
                                textColor: Colors.white,
                                textAlign: TextAlign.left,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                              CustomText(
                                context: context,
                                text: host == null ? "" : "@${host.username}",
                                textColor: Colors.white,
                                textAlign: TextAlign.left,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
//                        isCommenting
//                            ? Container()
//                            :
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24.0), bottomRight: Radius.circular(24.0)),
                          ),
                          height: isCommenting ? 100 : 250,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: eventChat(),
                        ),
                        Container(
                          height: 120,
                          child: _toolbar(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
