import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class ScanForEventsPage extends StatefulWidget {
  final WebblenUser currentUser;

  ScanForEventsPage({
    this.currentUser,
  });

  @override
  _ScanForEventsPageState createState() => _ScanForEventsPageState();
}

class _ScanForEventsPageState extends State<ScanForEventsPage> {
  WebblenUser currentUser;
  bool isLoading = true;
  List<Event> events = [];

  Future<void> loadEvents() async {
    EventDataService().getEventsForTicketScans(widget.currentUser.uid).then((res) {
      events = res;
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
        ),
        child: Fonts().textW700(
          'Select Event',
          20.0,
          Colors.black,
          TextAlign.center,
        ),
      ),
      leading: BackButton(
        color: FlatColors.darkGray,
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? LoadingScreen(
              context: context,
              loadingDescription: 'Loading Your Communities...',
            )
          : Container(
              color: Colors.white,
              child: LiquidPullToRefresh(
                color: FlatColors.webblenRed,
                onRefresh: loadEvents,
                child: events.isEmpty
                    ? ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 64.0,
                          ),
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW500(
                              'You Currently Have No Events with Tickets',
                              14.0,
                              Colors.black45,
                              TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW300(
                              'Pull Down To Refresh',
                              14.0,
                              Colors.black26,
                              TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Container(
                              height: 90.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.0),
                                boxShadow: ([
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 1.8,
                                    spreadRadius: 0.5,
                                    offset: Offset(0.0, 3.0),
                                  ),
                                ]),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18.0),
                                onTap: () => PageTransitionService(context: context, currentUser: currentUser, event: events[index]).openTicketScanner(),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Fonts().textW700(
                                                  events[index].title,
                                                  22.0,
                                                  Colors.black,
                                                  TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              MediaQuery(
                                                data: MediaQuery.of(context).copyWith(
                                                  textScaleFactor: 1.0,
                                                ),
                                                child: Fonts().textW400(
                                                  events[index].communityAreaName + "/" + events[index].communityName,
                                                  15.0,
                                                  FlatColors.lightAmericanGray,
                                                  TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
    );
  }
}
