import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_event/event_row.dart';

class EventsPage extends StatefulWidget {
  final WebblenUser currentUser;
  final double currentLat;
  final double currentLon;
  final String areaName;
  final Key key;

  EventsPage({
    this.currentUser,
    this.currentLat,
    this.currentLon,
    this.areaName,
    this.key,
  });

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController _scrollController;
//  List<Event> events = [];
  List<Event> myEvents = [];
  List<Event> standardEvents = [];
  List<Event> foodDrinkEvents = [];
  List<Event> saleDiscountEvents = [];
  bool isLoading = true;

  Future<Null> getEvents() async {
    EventDataService()
        .getEventsNearLocation(
      widget.currentLat,
      widget.currentLon,
      false,
    )
        .then((result) {
      if (result.isEmpty) {
        isLoading = false;
        setState(() {});
      } else {
        standardEvents = result.where((e) => e.eventType == 'standard').toList(growable: true);
        foodDrinkEvents = result.where((e) => e.eventType == 'foodDrink').toList(growable: true);
        saleDiscountEvents = result.where((e) => e.eventType == 'saleDiscount').toList(growable: true);
        standardEvents.sort((eventA, eventB) => eventA.startDateInMilliseconds.compareTo(eventB.startDateInMilliseconds));
        foodDrinkEvents.sort((eventA, eventB) => eventA.startDateInMilliseconds.compareTo(eventB.startDateInMilliseconds));
        saleDiscountEvents.sort((eventA, eventB) => eventA.startDateInMilliseconds.compareTo(eventB.startDateInMilliseconds));
        EventDataService().getCreatedEvents(widget.currentUser.uid).then((res) {
          myEvents = res;
          myEvents.sort((eventA, eventB) => eventB.startDateInMilliseconds.compareTo(eventA.startDateInMilliseconds));
          isLoading = false;
          setState(() {});
        });
      }
    });
  }

  Future<void> refreshData() async {
    standardEvents = [];
    foodDrinkEvents = [];
    saleDiscountEvents = [];
    myEvents = [];
    getEvents();
  }

  void transitionToCommunityPage(Event event) async {
    ShowAlertDialogService().showLoadingCommunityDialog(
      context,
      event.communityAreaName,
      event.communityName,
    );
    CommunityDataService()
        .getCommunityByName(
      event.communityAreaName,
      event.communityName,
    )
        .then((com) {
      if (com != null) {
        Navigator.of(context).pop();
        PageTransitionService(
          context: context,
          currentUser: widget.currentUser,
          community: com,
        ).transitionToCommunityProfilePage();
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          'Uh Oh...',
          'There was an issue loading this community. Please try again later',
        );
      }
    });
  }

  void transitionToShareEventPage(Event event) async {
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      event: event,
    ).transitionToChatInviteSharePage();
  }

  Widget listEvents(List<Event> eventsToList) {
    return LiquidPullToRefresh(
      color: FlatColors.webblenRed,
      onRefresh: refreshData,
      child: new ListView.builder(
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: eventsToList.length,
        itemBuilder: (context, index) {
          return ComEventRow(
              event: eventsToList[index],
              showCommunity: true,
              currentUser: widget.currentUser,
              transitionToComAction: () => transitionToCommunityPage(eventsToList[index]),
              shareEventAction: () => transitionToShareEventPage(eventsToList[index]),
              eventPostAction: () => PageTransitionService(
                    context: context,
                    currentUser: widget.currentUser,
                    event: eventsToList[index],
                    eventIsLive: false,
                  ).transitionToEventPage());
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      length: 4,
      vsync: this,
    );
    _scrollController = ScrollController();
    //EventDataService().convertEventData();
    getEvents();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(
        "Events",
        24.0,
        Colors.black,
        TextAlign.center,
      ),
      leading: BackButton(
        color: Colors.black,
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => PageTransitionService(
                context: context,
                currentUser: widget.currentUser,
                areaName: widget.areaName,
              ).transitionToSearchPage(),
              icon: Icon(
                FontAwesomeIcons.search,
                size: 20.0,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () => PageTransitionService(
                context: context,
                uid: widget.currentUser.uid,
                action: 'newEvent',
              ).transitionToMyCommunitiesPage(),
              icon: Icon(
                FontAwesomeIcons.plus,
                size: 20.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        indicatorColor: FlatColors.webblenRed,
        labelColor: FlatColors.darkGray,
        isScrollable: true,
        labelStyle: TextStyle(
          fontFamily: 'Barlow',
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            text: 'Nearby Events',
          ),
          Tab(
            text: 'Food/Drink Specials',
          ),
          Tab(
            text: 'Sales & Discounts',
          ),
          Tab(
            text: 'My Events',
          ),
        ],
        controller: _tabController,
      ),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: appBar,
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            //EVENTS
            Container(
              key: PageStorageKey('key0'),
              color: Colors.white,
              child: isLoading
                  ? LoadingScreen(
                      context: context,
                      loadingDescription: 'Loading Events...',
                    )
                  : standardEvents.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                  ),
                                  child: Fonts().textW300(
                                    "No Community You're Following Has Upcoming Events",
                                    16.0,
                                    FlatColors.lightAmericanGray,
                                    TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomColorButton(
                                  text: 'Post a Flash Event',
                                  textColor: FlatColors.darkGray,
                                  backgroundColor: Colors.white,
                                  height: 45.0,
                                  width: 300,
                                  hPadding: 8.0,
                                  vPadding: 8.0,
                                  onPressed: () => () => PageTransitionService(
                                        context: context,
                                        uid: widget.currentUser.uid,
                                      ).transitionToNewFlashEventPage(),
                                )
                              ],
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.white,
                          child: listEvents(standardEvents),
                        ),
            ),
            //FOOD DRINK SPECIALS
            Container(
              key: PageStorageKey('key1'),
              color: Colors.white,
              child: isLoading
                  ? LoadingScreen(
                      context: context,
                      loadingDescription: 'Loading Events...',
                    )
                  : foodDrinkEvents.isEmpty
                      ? Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 64.0),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                  ),
                                  child: Fonts().textW300(
                                    "We Couldn't Find Any Food or Drink Specials Nearby ",
                                    14.0,
                                    FlatColors.lightAmericanGray,
                                    TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomColorButton(
                                  text: 'Post a Flash Food/Drink Special',
                                  textColor: FlatColors.darkGray,
                                  backgroundColor: Colors.white,
                                  height: 45.0,
                                  width: 300,
                                  hPadding: 8.0,
                                  vPadding: 8.0,
                                  onPressed: () => PageTransitionService(
                                    context: context,
                                    uid: widget.currentUser.uid,
                                  ).transitionToNewFlashEventPage(),
                                ),
                              ],
                            )
                          ],
                        )
                      : Container(
                          color: Colors.white,
                          child: listEvents(foodDrinkEvents),
                        ),
            ),
            //SALES & DISCOUNT EVENTS
            Container(
              key: PageStorageKey('key2'),
              color: Colors.white,
              child: isLoading
                  ? LoadingScreen(
                      context: context,
                      loadingDescription: 'Loading Events...',
                    )
                  : saleDiscountEvents.isEmpty
                      ? Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 64.0),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                  ),
                                  child: Fonts().textW300(
                                    "We Couldn't Find Any Sales or Discounts Nearby",
                                    14.0,
                                    FlatColors.lightAmericanGray,
                                    TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomColorButton(
                                  text: 'Post a Flash Sale/Promotion',
                                  textColor: FlatColors.darkGray,
                                  backgroundColor: Colors.white,
                                  height: 45.0,
                                  width: 300,
                                  hPadding: 8.0,
                                  vPadding: 8.0,
                                  onPressed: () => PageTransitionService(
                                    context: context,
                                    uid: widget.currentUser.uid,
                                  ).transitionToNewFlashEventPage(),
                                ),
                              ],
                            )
                          ],
                        )
                      : Container(
                          color: Colors.white,
                          child: listEvents(saleDiscountEvents),
                        ),
            ),
            //MY EVENTS
            Container(
              key: PageStorageKey('key3'),
              color: Colors.white,
              child: isLoading
                  ? LoadingScreen(
                      context: context,
                      loadingDescription: 'Loading Events...',
                    )
                  : myEvents.isEmpty
                      ? Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 64.0),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                  ),
                                  child: Fonts().textW300(
                                    "Loading Your Events...",
                                    14.0,
                                    FlatColors.lightAmericanGray,
                                    TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomColorButton(
                                  text: 'Create an Event',
                                  textColor: FlatColors.darkGray,
                                  backgroundColor: Colors.white,
                                  height: 45.0,
                                  width: 300,
                                  hPadding: 8.0,
                                  vPadding: 8.0,
                                  onPressed: () => PageTransitionService(
                                    context: context,
                                    uid: widget.currentUser.uid,
                                    action: 'newEvent',
                                  ).transitionToMyCommunitiesPage(),
                                ),
                              ],
                            )
                          ],
                        )
                      : Container(
                          color: Colors.white,
                          child: listEvents(myEvents),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
