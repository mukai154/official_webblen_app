import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_event/event_check_in_row.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';


class StreamUserPastEvents extends StatelessWidget {

  final WebblenUser currentUser;
  StreamUserPastEvents({this.currentUser});

  @override
  Widget build(BuildContext context) {

    CollectionReference eventRef = Firestore.instance.collection("events");

    return StreamBuilder(
      stream: eventRef
          .where('attendees', arrayContains: currentUser.uid)
          .where('pointsDistributedToUsers', isEqualTo: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> docSnapshots) {
        if (!docSnapshots.hasData) {
          return LoadingScreen(context: context, loadingDescription: 'Locating Available Check Ins',);
        } else {
          if (docSnapshots.data.documents.isEmpty) return Fonts().textW400("No Events Found", 16.0, FlatColors.darkGray, TextAlign.center);
          return ListView.builder(
            itemCount: docSnapshots.data.documents.length,
            itemBuilder: (context, index){
              Event event = Event.fromMap(docSnapshots.data.documents[index].data);
              return ComEventRow(
                event: event,
                showCommunity: true,
                currentUser: currentUser,
                eventPostAction: () => PageTransitionService(context: context, currentUser: currentUser, event: event, eventIsLive: true).transitionToEventPage(),
              );
            },
          );
        }
      },
    );
  }
}
