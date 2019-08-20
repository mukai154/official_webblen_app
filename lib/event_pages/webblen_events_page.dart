import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/event_data.dart';

class WebblenEventsFeedPage extends StatefulWidget {

  final WebblenUser currentUser;
  final List<Event> events;
  WebblenEventsFeedPage({this.currentUser, this.events});

  @override
  _WebblenEventsFeedPageState createState() => _WebblenEventsFeedPageState();
}

class _WebblenEventsFeedPageState extends State<WebblenEventsFeedPage> {

  ScrollController _scrollController;
  List<Event> events = [];
  bool isLoading = true;

  Future<Null> getEvents() async {
    EventDataService().getExclusiveWebblenEvents().then((result){
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
                leading: BackButton(color: Colors.black),
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                title: boxIsScrolled ? Fonts().textW700('Webblen Events', 20, Colors.black, TextAlign.left) : Container(),
                pinned: true,
                expandedHeight: 80.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 70,
                          margin: EdgeInsets.only(left: 16, top: 16, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Fonts().textW700('Webblen Events', 20, Colors.black, TextAlign.center),
                                flex: 6,
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
                    child: Fonts().textW300("There Are No Webblen Events Coming Up", 16.0, FlatColors.lightAmericanGray, TextAlign.center),
                  )
                ],
              ),
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
