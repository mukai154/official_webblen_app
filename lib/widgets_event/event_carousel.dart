import 'package:flutter/material.dart';
import 'package:webblen/models/event.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'event_row.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';

class EventCarousel extends StatelessWidget {

  final WebblenUser currentUser;
  final List<Event> events;


  EventCarousel({this.currentUser, this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: CarouselSlider(
          items:  BuildEvents(context: context, events: events, size: MediaQuery.of(context).size.width * 0.42, currentUser: currentUser).build(),
          height: MediaQuery.of(context).size.height * 0.22 + 30,
          viewportFraction: 0.40,
          autoPlay: false,
          enlargeCenterPage: false,
          //autoPlayAnimationDuration: Duration(seconds: 2),
          //autoPlayCurve: Curves.ease,
        ),
      ),
    );
  }
}

class BuildEvents {

  final WebblenUser currentUser;
  final double size;
  final List<Event> events;
  final BuildContext context;

  BuildEvents({this.context, this.events, this.currentUser, this.size});

  List build(){
    List<Widget> eventTiles = List();
    for (int i = 0; i < events.length; i++) {
      eventTiles.add(
          EventCarouselTile(
            size: size,
            event: events[i],
            eventPostAction: () => PageTransitionService(context: context, currentUser: currentUser, event: events[i], eventIsLive: false).transitionToEventPage(),
            transitionToComAction: null,
          )
      );
    }
    return eventTiles;
  }

}
