import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';

import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';


class StreamPastEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final WebblenUser user;
  StreamPastEvents({this.currentUser, this.user});

  final CollectionReference eventRef = Firestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: eventRef
          .where('attendees', arrayContains: user.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Event> pastEvents = [];
        if (!snapshot.hasData) {
          return Center(child: Fonts().textW500('Loading Events...', 18.0, FlatColors.darkGray, TextAlign.center));
        } else {
          if (snapshot.data.documents.isEmpty) return Center(child: Fonts().textW300('@${user.username} has not attended any events', 18.0, FlatColors.darkGray, TextAlign.center));
          snapshot.data.documents.forEach((eventDoc){
            Event event = Event.fromMap(eventDoc.data);
            if (!pastEvents.contains(event)){
              pastEvents.add(event);
            }
          });
          pastEvents.sort((e1, e2) => e2.startDateInMilliseconds.compareTo(e1.startDateInMilliseconds));
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemCount: pastEvents.length,
            itemBuilder: (context, index){
              return ComEventRow(
                event: pastEvents[index],
                showCommunity: true,
                currentUser: currentUser,
                eventPostAction: () => PageTransitionService(context: context, event: pastEvents[index], currentUser: currentUser, eventIsLive: false).transitionToEventPage(),
              );
            },
          );
        }
      },
    );
  }
}

