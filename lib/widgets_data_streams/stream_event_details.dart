import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webblen/models/event.dart';

class StreamEventDetails extends StatelessWidget {

  final WebblenUser currentUser;
  final String detailType;
  final String eventKey;
  final Widget placeholderWidget;

  StreamEventDetails({this.currentUser, this.detailType, this.eventKey, this.placeholderWidget});

  @override
  Widget build(BuildContext context) {
    Widget detailWidget;
    
    DateFormat dateFormat = DateFormat("MMM d, y h:mma");

    return StreamBuilder(
      stream: Firestore.instance
          .collection('events')
          .document(eventKey)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) return Container();
        Event event = Event.fromMap(snapshot.data.data);
        if (detailType == 'caption'){
          detailWidget = Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Fonts().textW700('Details', 24.0, Colors.black, TextAlign.left),
                Fonts().textW500(event.description, 16.0, Colors.black, TextAlign.left),
              ],
            ),
          );
        } else if (detailType == 'date'){
          detailWidget = event.startDateInMilliseconds == null
          ? Container()
          : Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Icon(FontAwesomeIcons.calendar, size: 20.0, color: Colors.black),
                ],
              ),
              SizedBox(width: 4.0),
              Column(
                children: <Widget>[
                  SizedBox(height: 4.0),
                  Fonts().textW400(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(event.startDateInMilliseconds)), 16.0, Colors.black, TextAlign.left),
                ],
              ),
            ],
          );
        }
        return detailWidget;
      },
    );
  }
}