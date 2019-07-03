import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/firebase_services/community_data.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_button.dart';

class EventFeedPage extends StatefulWidget {

  final WebblenUser currentUser;
  final VoidCallback discoverAction;
  final Key key;
  EventFeedPage({this.currentUser, this.discoverAction, this.key});

  @override
  _EventFeedPageState createState() => _EventFeedPageState();
}

class _EventFeedPageState extends State<EventFeedPage> {

  List<Event> events = [];
  bool isLoading = true;

  Future<Null> getEvents() async {
    if (widget.currentUser.followingCommunities == null || widget.currentUser.followingCommunities.isEmpty){
      setState(() {
        isLoading = false;
      });
    } else {
      widget.currentUser.followingCommunities.forEach((key, val) async {
        String areaName = key;
        List communities = val;
        communities.forEach((com) async {
          await CommunityDataService().getEventsFromCommunities(areaName, com).then((result){
            events.addAll(result);
            if (widget.currentUser.followingCommunities.keys.last == key &&  communities.last == com){
              events.sort((eventA, eventB) => eventB.startDateInMilliseconds.compareTo(eventA.startDateInMilliseconds));
              if (this.mounted){
                setState(() {
                  isLoading = false;
                });
              }
            }
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen(context: context, loadingDescription: 'Loading Events...')
        : events.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Fonts().textW300("No Community You're Following Has Upcoming Events", 16.0, FlatColors.lightAmericanGray, TextAlign.center),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomColorButton(
                    text: 'Discover Events Near Me',
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 300,
                    hPadding: 8.0,
                    vPadding: 8.0,
                    onPressed: widget.discoverAction,
                  )
                ],
              )
            ],
          )
        : Container(
          color: FlatColors.clouds,
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 8.0),
            itemCount: events.length,
            itemBuilder: (context, index){
              return ComEventRow(
                  event: events[index],
                  showCommunity: true,
                  currentUser: widget.currentUser,
                  eventPostAction: () => PageTransitionService(context: context, currentUser: widget.currentUser, event: events[index], eventIsLive: false).transitionToEventPage()
              );
            },
          ),
        );
  }
}
