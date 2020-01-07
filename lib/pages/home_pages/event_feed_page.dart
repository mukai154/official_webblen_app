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

class EventFeedPage extends StatefulWidget {
  final WebblenUser currentUser;
  final VoidCallback discoverAction;
  final double currentLat;
  final double currentLon;
  final String areaName;
  final Key key;

  EventFeedPage({
    this.currentUser,
    this.discoverAction,
    this.currentLat,
    this.currentLon,
    this.areaName,
    this.key,
  });

  @override
  _EventFeedPageState createState() => _EventFeedPageState();
}

class _EventFeedPageState extends State<EventFeedPage>
    with SingleTickerProviderStateMixin {
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController _scrollController;
//  List<Event> events = [];
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
        standardEvents = result
            .where((e) => e.eventType == 'standard')
            .toList(growable: true);
        foodDrinkEvents = result
            .where((e) => e.eventType == 'foodDrink')
            .toList(growable: true);
        saleDiscountEvents = result
            .where((e) => e.eventType == 'saleDiscount')
            .toList(growable: true);
        standardEvents.sort((eventA, eventB) => eventA.startDateInMilliseconds
            .compareTo(eventB.startDateInMilliseconds));
        foodDrinkEvents.sort((eventA, eventB) => eventA.startDateInMilliseconds
            .compareTo(eventB.startDateInMilliseconds));
        saleDiscountEvents.sort((eventA, eventB) => eventA
            .startDateInMilliseconds
            .compareTo(eventB.startDateInMilliseconds));
        isLoading = false;
        setState(() {});
      }
    });
  }

  Future<void> refreshData() async {
    standardEvents = [];
    foodDrinkEvents = [];
    saleDiscountEvents = [];
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

  Widget listEvents() {
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
        itemCount: standardEvents.length,
        itemBuilder: (context, index) {
          return ComEventRow(
              event: standardEvents[index],
              showCommunity: true,
              currentUser: widget.currentUser,
              transitionToComAction: () =>
                  transitionToCommunityPage(standardEvents[index]),
              shareEventAction: () =>
                  transitionToShareEventPage(standardEvents[index]),
              eventPostAction: () => PageTransitionService(
                    context: context,
                    currentUser: widget.currentUser,
                    event: standardEvents[index],
                    eventIsLive: false,
                  ).transitionToEventPage());
        },
      ),
    );
  }

  Widget listFoodDrinkEvents() {
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
        itemCount: foodDrinkEvents.length,
        itemBuilder: (context, index) {
          return ComEventRow(
              event: foodDrinkEvents[index],
              showCommunity: true,
              currentUser: widget.currentUser,
              transitionToComAction: () =>
                  transitionToCommunityPage(foodDrinkEvents[index]),
              shareEventAction: () =>
                  transitionToShareEventPage(foodDrinkEvents[index]),
              eventPostAction: () => PageTransitionService(
                    context: context,
                    currentUser: widget.currentUser,
                    event: foodDrinkEvents[index],
                    eventIsLive: false,
                  ).transitionToEventPage());
        },
      ),
    );
  }

  Widget listSaleDiscountEvents() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
      ),
      itemCount: saleDiscountEvents.length,
      itemBuilder: (context, index) {
        return ComEventRow(
            event: saleDiscountEvents[index],
            showCommunity: true,
            currentUser: widget.currentUser,
            transitionToComAction: () =>
                transitionToCommunityPage(saleDiscountEvents[index]),
            shareEventAction: () =>
                transitionToShareEventPage(saleDiscountEvents[index]),
            eventPostAction: () => PageTransitionService(
                  context: context,
                  currentUser: widget.currentUser,
                  event: saleDiscountEvents[index],
                  eventIsLive: false,
                ).transitionToEventPage());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      length: 3,
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
    final appBar = PreferredSize(
      preferredSize: MediaQuery.of(context).size.height > 667.0
          ? Size.fromHeight(105.0)
          : Size.fromHeight(96.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height:
                      MediaQuery.of(context).size.height > 667.0 ? 90.0 : 60.0,
                  margin: EdgeInsets.only(
                    left: 16,
                    top: 8.0,
                    right: 8,
                  ),
                  child: Padding(
                    padding: MediaQuery.of(context).size.height > 667.0
                        ? EdgeInsets.only(
                            top: 40.0,
                          )
                        : EdgeInsets.only(
                            top: 20.0,
                          ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0,
                            ),
                            child: Fonts().textW700(
                              'Events',
                              40,
                              Colors.black,
                              TextAlign.left,
                            ),
                          ),
                          flex: 6,
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () => PageTransitionService(
                              context: context,
                              currentUser: widget.currentUser,
                              areaName: widget.areaName,
                            ).transitionToSearchPage(),
                            icon: Icon(
                              FontAwesomeIcons.search,
                              size: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () => PageTransitionService(
                              context: context,
                              uid: widget.currentUser.uid,
                              action: 'newEvent',
                            ).transitionToMyCommunitiesPage(),
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              size: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          flex: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                TabBar(
                  indicatorColor: FlatColors.webblenRed,
                  labelColor: FlatColors.darkGray,
                  isScrollable: true,
                  labelStyle: TextStyle(
                    fontFamily: 'Barlow',
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      text: 'Events',
                    ),
                    Tab(
                      text: 'Food/Drink Specials',
                    ),
                    Tab(
                      text: 'Sales & Discounts',
                    ),
                  ],
                  controller: _tabController,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return DefaultTabController(
      length: 3,
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
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 16,
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
                          child: listEvents(),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 16,
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
                          child: listFoodDrinkEvents(),
                        ),
            ),
            //SALES & DEALS
            Container(
              key: PageStorageKey('key2'),
              color: Colors.white,
              child: isLoading
                  ? LoadingScreen(
                      context: context,
                      loadingDescription:
                          'Searching for Special Sales & Discounts...',
                    )
                  : saleDiscountEvents.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 16,
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
                                  text: 'Post a Flash Sale',
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
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.white,
                          child: LiquidPullToRefresh(
                            color: FlatColors.webblenRed,
                            onRefresh: refreshData,
                            child: listSaleDiscountEvents(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
