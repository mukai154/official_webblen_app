import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_event/event_row.dart';

class EventList extends StatelessWidget {
  final WebblenUser currentUser;
  final List<WebblenEvent> events;
  final VoidCallback refreshData;

  EventList({
    this.currentUser,
    this.events,
    this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: refreshData,
      color: FlatColors.webblenRed,
      child: events.isEmpty
          ? ListView(
              children: <Widget>[
                SizedBox(
                  height: 64.0,
                ),
                Fonts().textW500(
                  'No Past Events Found',
                  14.0,
                  Colors.black45,
                  TextAlign.center,
                ),
                SizedBox(
                  height: 8.0,
                ),
                Fonts().textW300(
                  'Pull Down To Refresh',
                  14.0,
                  Colors.black26,
                  TextAlign.center,
                ),
              ],
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ComEventRow(
                  event: events[index],
                  showCommunity: true,
                  currentUser: currentUser,
                  eventPostAction: () => PageTransitionService(
                    context: context,
                    event: events[index],
                    currentUser: currentUser,
                    eventIsLive: false,
                  ).transitionToEventPage(),
                );
              },
            ),
    );
  }
}
