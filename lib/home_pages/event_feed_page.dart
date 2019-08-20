import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/event_data.dart';

class EventFeedPage extends StatefulWidget {

  final WebblenUser currentUser;
  final VoidCallback discoverAction;
  final double currentLat;
  final double currentLon;
  final String areaName;
  final Key key;
  EventFeedPage({this.currentUser, this.discoverAction, this.currentLat, this.currentLon, this.areaName, this.key});

  @override
  _EventFeedPageState createState() => _EventFeedPageState();
}

class _EventFeedPageState extends State<EventFeedPage> {

  ScrollController _scrollController;
  List<Event> events = [];
  bool isLoading = true;

  Future<Null> getEvents() async {
    EventDataService().getEventsNearLocation(widget.currentLat, widget.currentLon, false).then((result){
      if (result.isEmpty){
        isLoading = false;
        setState(() {});
      } else {
        events = result;
        events.sort((eventA, eventB) => eventA.startDateInMilliseconds.compareTo(eventB.startDateInMilliseconds));
        isLoading = false;
        setState(() {});
      }
    });
  }

  Future<void> refreshData() async{
    events = [];
    getEvents();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    //EventDataService().convertEventData();
    getEvents();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled){
            return <Widget>[
              SliverAppBar(
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                title: boxIsScrolled ? Fonts().textW700('Events', 24, Colors.black, TextAlign.left) : Container(),
                pinned: true,
                actions: <Widget>[
                  boxIsScrolled ?
                  IconButton(
                    onPressed: () => PageTransitionService(context: context, currentUser: widget.currentUser, areaName: widget.areaName).transitionToSearchPage(),
                    icon: Icon(FontAwesomeIcons.search, size: 18.0, color: Colors.black),
                  )
                      : Container(),
                  boxIsScrolled ?
                  IconButton(
                    onPressed: () => PageTransitionService(context: context, uid: widget.currentUser.uid, newEventOrPost: 'event').transitionToChooseCommunityPage(),
                    icon: Icon(FontAwesomeIcons.plus, size: 18.0, color: Colors.black),
                  )
                  : Container(),
                ],
                expandedHeight: 80.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 70,
                          margin: EdgeInsets.only(left: 16, top: 30, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Fonts().textW700('Events', 40, Colors.black, TextAlign.left),
                                flex: 6,
                              ),
                              Expanded(
                                child: IconButton(
                                  onPressed: () => PageTransitionService(context: context, currentUser: widget.currentUser, areaName: widget.areaName).transitionToSearchPage(),
                                  icon: Icon(FontAwesomeIcons.search, size: 18.0, color: Colors.black),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: IconButton(
                                  onPressed: () => PageTransitionService(context: context, uid: widget.currentUser.uid, newEventOrPost: 'event').transitionToChooseCommunityPage(),
                                  icon: Icon(FontAwesomeIcons.plus, size: 18.0, color: Colors.black),
                                ),
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: isLoading
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
                  color: Colors.white,
                  child: LiquidPullToRefresh(
                      color: FlatColors.webblenRed,
                      onRefresh: refreshData,
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
                  ),

                ),
        )
    );
  }
}
