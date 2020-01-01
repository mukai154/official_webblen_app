import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';

class BuildSentMessage extends StatelessWidget {
  final WebblenUser currentUser;
  final WebblenChatMessage chatMessage;
  final VoidCallback tapAction;
  final VoidCallback longPressAction;

  BuildSentMessage({this.currentUser, this.chatMessage, this.tapAction, this.longPressAction});

  Widget textMessage() {
    return Container(
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      constraints: BoxConstraints(minWidth: 20, maxWidth: 270),
      decoration: BoxDecoration(
        color: FlatColors.webblenRed,
        borderRadius: BorderRadius.circular(24.0),
      ),
      margin: EdgeInsets.only(bottom: 16.0, right: 10.0),
      child: Fonts().textW500(chatMessage.messageContent, 16.0, Colors.white, TextAlign.left),
    );
  }

  Widget imageMessage() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0, right: 10.0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: chatMessage.messageContent,
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
          placeholder: (context, url) => CustomCircleProgress(20.0, 20.0, 20.0, 20.0, FlatColors.blueGrayLowOpacity),
          errorWidget: (context, url, error) => Icon(FontAwesomeIcons.exclamation),
        ),
      ),
    );
  }

  Widget eventMessage() {
    return Column(
      children: <Widget>[
        Fonts().textW400("You shared an event", 12.0, Colors.black45, TextAlign.right),
        Container(margin: EdgeInsets.only(bottom: 16.0, right: 10.0), child: EventMessage(currentUser: currentUser, eventKey: chatMessage.messageContent))
      ],
    );
  }

  Widget buildSentMessage() {
    bool showTime = false;
    if (DateTime.now().millisecondsSinceEpoch - chatMessage.timestamp > 18000000) {
      showTime = true;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        showTime
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Fonts().textW400(TimeCalc().getPastTimeFromMilliseconds(chatMessage.timestamp), 12.0, FlatColors.lightAmericanGray, TextAlign.right),
                  )
                ],
              )
            : Container(),
        chatMessage.messageType == "text"
            ? textMessage()
            : chatMessage.messageType == "image" ? imageMessage() : chatMessage.messageType == "initial" ? Container() : eventMessage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        buildSentMessage(),
      ],
    );
  }
}

class BuildReceivedMessage extends StatelessWidget {
  final WebblenUser currentUser;
  final WebblenChatMessage chatMessage;
  final VoidCallback tapAction;
  final VoidCallback longPressAction;

  BuildReceivedMessage({this.currentUser, this.chatMessage, this.tapAction, this.longPressAction});

  Widget textMessage() {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 10.0),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      constraints: BoxConstraints(minWidth: 20, maxWidth: 270),
      decoration: BoxDecoration(
        color: FlatColors.clouds,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Fonts().textW500(chatMessage.messageContent, 16.0, FlatColors.darkGray, TextAlign.left),
    );
  }

  Widget imageMessage() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0, right: 10.0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: chatMessage.messageContent,
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
          placeholder: (context, url) => CustomCircleProgress(20.0, 20.0, 20.0, 20.0, FlatColors.blueGrayLowOpacity),
          errorWidget: (context, url, error) => Icon(FontAwesomeIcons.exclamation),
        ),
      ),
    );
  }

  Widget eventMessage() {
    return Column(
      children: <Widget>[
        Fonts().textW400("@${chatMessage.username} shared an event", 12.0, Colors.black45, TextAlign.right),
        GestureDetector(
          onTap: tapAction,
          child: Container(
              margin: EdgeInsets.only(left: 8.0, bottom: 16.0, right: 10.0),
              child: EventMessage(currentUser: currentUser, eventKey: chatMessage.messageContent)),
        ),
      ],
    );
  }

  Widget buildReceivedMessage() {
    bool showTime = false;
    if (DateTime.now().millisecondsSinceEpoch - chatMessage.timestamp > 18000000) {
      showTime = true;
    }
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          showTime
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          Fonts().textW400(TimeCalc().getPastTimeFromMilliseconds(chatMessage.timestamp), 12.0, FlatColors.lightAmericanGray, TextAlign.right),
                    )
                  ],
                )
              : Container(),
          Row(
            children: <Widget>[
              UserProfilePicFromUID(uid: chatMessage.uid, size: 45),
              chatMessage.messageType == "text" ? textMessage() : chatMessage.messageType == "initial" ? Container() : eventMessage()
            ],
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      margin: EdgeInsets.only(bottom: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildReceivedMessage();
  }
}

class EventMessage extends StatefulWidget {
  final WebblenUser currentUser;
  final String eventKey;
  EventMessage({this.currentUser, this.eventKey});

  @override
  _EventMessageState createState() => _EventMessageState();
}

class _EventMessageState extends State<EventMessage> {
  bool isLoading = true;
  Event event;

  @override
  void initState() {
    super.initState();
    EventDataService().getEventByKey(widget.eventKey).then((res) {
      event = res;
      isLoading = false;
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomCircleProgress(40.0, 40.0, 40.0, 40.0, Colors.black38)
        : event == null
            ? Fonts().textW400("This Event is No Longer Available", 10.0, Colors.black26, TextAlign.right)
            : GestureDetector(
                onTap: () => PageTransitionService(context: context, event: event, eventIsLive: false, currentUser: widget.currentUser).transitionToEventPage(),
                child: EventChatRow(event: event));
  }
}
