import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_event/event_check_in_row.dart';

import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/event.dart';


class StreamActiveNearbyEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final VoidCallback createFlashEventAction;
  final double currentLat;
  final double currentLon;

  StreamActiveNearbyEvents({this.currentUser, this.createFlashEventAction, this.currentLat, this.currentLon});

  @override
  Widget build(BuildContext context) {


    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: currentLat, longitude: currentLon);
    CollectionReference eventRef = Firestore.instance.collection("events");

    int currentDateTime = DateTime.now().millisecondsSinceEpoch;


    Widget noEventsFoundWidget = Container(
      width: MediaQuery.of(context).size.width,
      child: new Column(
        children: <Widget>[
          SizedBox(height: 160.0),
          new Container(
            height: 85.0,
            width: 85.0,
            child: new Image.asset("assets/images/scan.png", fit: BoxFit.scaleDown),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child:
            Fonts().textW400("There are Currently No Availabe Events Nearby", 16.0, FlatColors.darkGray, TextAlign.center),
            //new Text("There are Currently No Availabe Events Nearby", style: Fonts.noEventsFont, textAlign: TextAlign.center),
          ),
          SizedBox(height: 8.0),
          CustomColorButton(
            text: "Create Flash Event",
            textColor: FlatColors.darkGray,
            backgroundColor: Colors.white,
            height: 45.0,
            width: 200.0,
            onPressed: createFlashEventAction,
          ),
        ],
      ),
    );

    return StreamBuilder(
      stream: geo.collection(collectionRef: eventRef)
          .within(center: center, radius: 1, strictMode: true, field: 'location'),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> docSnapshots) {
        if (!docSnapshots.hasData) {
          return LoadingScreen(context: context, loadingDescription: 'Locating Available Check Ins',);
        } else {
          docSnapshots.data.removeWhere((doc) => doc['recurrence'] != 'none');
          docSnapshots.data.removeWhere((doc) => currentDateTime < doc["startDateInMilliseconds"] || currentDateTime > doc["endDateInMilliseconds"]);
          if (docSnapshots.data.isEmpty){
            return noEventsFoundWidget;
          } else {
            return ListView.builder(
              //padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index){
                Event event = Event.fromMap(docSnapshots.data[index].data);
                return NearbyEventCheckInRow (
                  uid: currentUser.uid,
                  event: event,
                  viewEventAction: () => PageTransitionService(context: context, currentUser: currentUser, event: event, eventIsLive: true).transitionToEventPage(),
                );
              },
              itemCount: docSnapshots.data.length,
            );
          }
        }
      },
    );
  }
}

class StreamNearbyEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final double currentLat;
  final double currentLon;

  StreamNearbyEvents({this.currentUser, this.currentLat, this.currentLon});

  @override
  Widget build(BuildContext context) {


    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: currentLat, longitude: currentLon);
    CollectionReference eventRef = Firestore.instance.collection("events");


    return StreamBuilder(
      stream: geo.collection(collectionRef: eventRef)
          .within(center: center, radius: 20, field: 'location'),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> docSnapshots) {
        if (!docSnapshots.hasData) {
          return LoadingScreen(context: context, loadingDescription: 'Locating Events...',);
        } else {
          docSnapshots.data.removeWhere((doc) => doc['recurrence'] != 'none');
          docSnapshots.data.removeWhere((doc) => doc["startDateInMilliseconds"] == null);
          docSnapshots.data.removeWhere((doc) => doc["startDateInMilliseconds"] < DateTime.now().millisecondsSinceEpoch && doc["endDateInMilliseconds"] < DateTime.now().millisecondsSinceEpoch);
          if (docSnapshots.data.isEmpty){
            return Padding(
              padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
              child: Fonts().textW300('No events found in this area', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
            );
          } else {
            List<Event> events = [];
            docSnapshots.data.forEach((docSnap){
              Event event = Event.fromMap(docSnap.data);
              if (!events.contains(event)){
                events.add(event);
              }
            });
            events.sort((eventA, eventB) => eventA.startDateInMilliseconds.compareTo(eventB.startDateInMilliseconds));
            return ListView.builder(
              //padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index){
                return ComEventRow(
                  event: events[index],
                  showCommunity: true,
                  currentUser: currentUser,
                  eventPostAction: () => PageTransitionService(context: context, currentUser: currentUser, event: events[index], eventIsLive: false).transitionToEventPage(),
                );
              },
              itemCount: events.length,
            );
          }
        }
      },
    );
  }
}


