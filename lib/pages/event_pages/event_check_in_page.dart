import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/widgets_event/event_check_in_row.dart';
import 'package:webblen/widgets/widgets_event/event_no_check_in_found.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class EventCheckInPage extends StatefulWidget {
  final WebblenUser currentUser;

  EventCheckInPage({
    this.currentUser,
  });

  @override
  _EventCheckInPageState createState() => _EventCheckInPageState();
}

class _EventCheckInPageState extends State<EventCheckInPage> {
  bool isLoading = true;
  double currentLat;
  double currentLon;
  List<Event> events = [];

  Future<Null> getEventsForCheckIn() async {
    EventDataService()
        .getEventsNearLocation(
      currentLat,
      currentLon,
      true,
    )
        .then((result) {
      if (result.isEmpty) {
        isLoading = false;
        setState(() {});
      } else {
        events = result;
        events.sort((eventA, eventB) => eventA.startDateInMilliseconds
            .compareTo(eventB.startDateInMilliseconds));
        isLoading = false;
        setState(() {});
      }
    });
  }

  Future<void> refreshData() async {
    events = [];
    getEventsForCheckIn();
  }

  void checkIntoEvent(Event event) async {
    ShowAlertDialogService().showLoadingDialog(context);
    EventDataService()
        .checkInAndUpdateEventPayout(
      event.eventKey,
      widget.currentUser.uid,
      widget.currentUser.ap,
    )
        .then((result) {
      int eventIndex =
          events.indexWhere((event) => event.eventKey == result.eventKey);
      events[eventIndex] = result;
      Navigator.of(context).pop();
      setState(() {});
      HapticFeedback.mediumImpact();
    });
  }

  void checkoutOfEvent(Event event) async {
    ShowAlertDialogService().showLoadingDialog(context);
    EventDataService()
        .checkoutAndUpdateEventPayout(
      event.eventKey,
      widget.currentUser.uid,
    )
        .then((result) {
      int eventIndex =
          events.indexWhere((event) => event.eventKey == result.eventKey);
      events[eventIndex] = result;
      Navigator.of(context).pop();
      setState(() {});
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void initState() {
    super.initState();
    LocationService().getCurrentLocation(context).then((result) {
      if (this.mounted) {
        if (result != null) {
          currentLat = result.latitude;
          currentLon = result.longitude;
          getEventsForCheckIn();
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        'Check In',
        IconButton(
          onPressed: () => PageTransitionService(
            context: context,
            uid: widget.currentUser.uid,
          ).transitionToNewFlashEventPage(),
          icon: Icon(
            FontAwesomeIcons.plusSquare,
            size: 24.0,
            color: FlatColors.darkGray,
          ),
        ),
      ),
      body: isLoading
          ? LoadingScreen(
              context: context,
              loadingDescription: 'locating available check ins...',
            )
          : Container(
              color: Colors.white,
              child: LiquidPullToRefresh(
                color: FlatColors.webblenRed,
                onRefresh: refreshData,
                child: events.isEmpty
                    ? ListView(
                        children: <Widget>[
                          EventNoCheckInFound(
                              createFlashEventAction: () =>
                                  PageTransitionService(
                                    context: context,
                                    uid: widget.currentUser.uid,
                                  ).transitionToNewFlashEventPage())
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return NearbyEventCheckInRow(
                            event: events[index],
                            uid: widget.currentUser.uid,
                            viewEventAction: () => PageTransitionService(
                              context: context,
                              currentUser: widget.currentUser,
                              event: events[index],
                              eventIsLive: false,
                            ).transitionToEventPage(),
                            checkInAction: () => checkIntoEvent(events[index]),
                            checkoutAction: () =>
                                checkoutOfEvent(events[index]),
                          );
                        },
                      ),
              ),
            ),
    );
  }
}
