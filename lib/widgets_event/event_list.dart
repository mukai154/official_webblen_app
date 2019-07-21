import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class EventList extends StatelessWidget {

  final WebblenUser currentUser;
  final List<Event> events;
  final VoidCallback refreshData;

  EventList({this.currentUser, this.events, this.refreshData});

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: refreshData,
      color: FlatColors.webblenRed,
      child: events.isEmpty
          ? ListView(
              children: <Widget>[
                SizedBox(height: 50.0),
                Fonts().textW500('No Past Events Found', 18.0, Colors.black26, TextAlign.center)
              ],
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemCount: events.length,
              itemBuilder: (context, index){
                return ComEventRow(
                  event: events[index],
                  showCommunity: true,
                  currentUser: currentUser,
                  eventPostAction: () => PageTransitionService(context: context, event: events[index], currentUser: currentUser, eventIsLive: false).transitionToEventPage(),
                );
              },
            ),
    );
  }
}
