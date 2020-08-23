import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_home_tiles/search_tile.dart';

class DigitalEventsPage extends StatefulWidget {
  final WebblenUser currentUser;

  DigitalEventsPage({
    this.currentUser,
  });

  @override
  _DigitalEventsPageState createState() => _DigitalEventsPageState();
}

class _DigitalEventsPageState extends State<DigitalEventsPage> with SingleTickerProviderStateMixin {
  final PageStorageBucket bucket = PageStorageBucket();
  ScrollController eventsScrollController;
  int resultsPerPage = 10;
  String areaName = "My Current Location";
  String areaCodeFilter;
  String eventTypeFilter = "None";
  String eventCategoryFilter = "None";
  //Event Results
  CollectionReference eventsRef = Firestore.instance.collection("events");

  List<DocumentSnapshot> eventResults = [];
  DocumentSnapshot lastEventDocSnap;
  bool isLoading = true;
  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;
  bool loadingAdditionalMyEvents = false;
  bool moreMyEventsAvailable = true;

  getEvents() async {
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef.where('d.isDigitalEvent', isEqualTo: true).orderBy('d.startDateTimeInMilliseconds', descending: false).limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      print(eventTypeFilter);
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      eventResults = querySnapshot.documents;
    }
    isLoading = false;
    setState(() {});
  }

  getAdditionalEvents() async {
    if (isLoading || !moreEventsAvailable || loadingAdditionalEvents) {
      return;
    }
    loadingAdditionalEvents = true;
    setState(() {});
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastEventDocSnap)
          .limit(resultsPerPage);
    }

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    eventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreEventsAvailable = false;
    }
    loadingAdditionalEvents = false;
    setState(() {});
  }

  Future<void> refreshData() async {
    eventResults = [];
    getEvents();
  }

  Future<void> refreshFromPreferences() async {
    Navigator.of(context).pop();
    isLoading = true;
    setState(() {});
    eventResults = [];
    getEvents();
  }

  showEventPreferenceDialog() {
    Widget widget = Container(
      height: 325.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            context: context,
            text: "Event Preferences",
            textColor: Colors.black,
            textAlign: TextAlign.center,
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 16.0),
          CustomText(
            context: context,
            text: "Location:",
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          GestureDetector(
            onTap: null,
            child: TextFieldContainer(
              height: 30.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomText(
                    context: context,
                    text: "$areaName",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          CustomText(
            context: context,
            text: "Category:",
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          TextFieldContainer(
            height: 35,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: DropdownButton(
                  style: TextStyle(fontSize: 12.0, color: Colors.black),
                  isExpanded: true,
                  underline: Container(),
                  value: eventCategoryFilter,
                  items: Strings.eventCategoryFilters.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      eventCategoryFilter = val;
                    });
                    Navigator.of(context).pop();
                    showEventPreferenceDialog();
                  }),
            ),
          ),
          SizedBox(height: 16.0),
          CustomText(
            context: context,
            text: "Type:",
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          TextFieldContainer(
            height: 35,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: DropdownButton(
                  style: TextStyle(fontSize: 12.0, color: Colors.black),
                  isExpanded: true,
                  underline: Container(),
                  value: eventTypeFilter,
                  items: Strings.eventTypeFilters.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      eventTypeFilter = val;
                    });
                    Navigator.of(context).pop();
                    showEventPreferenceDialog();
                  }),
            ),
          ),
          SizedBox(height: 16.0),
          CustomColorButton(
            text: "Apply",
            textColor: Colors.white,
            backgroundColor: CustomColors.darkMountainGreen,
            height: 45.0,
            width: 200.0,
            onPressed: () => refreshFromPreferences(),
          ),
        ],
      ),
    );
    ShowAlertDialogService().showFormDialog(context, widget);
  }

  Widget listEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: eventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: eventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(eventResults[index].data['d']));
          bool isOwner = event.authorID == widget.currentUser.uid ? true : false;
          return Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: eventResults.length - 1 == index ? 16.0 : 0),
            child: event.isDigitalEvent
                ? EventBlock(
                    event: event,
                    shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                    viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                    viewEventTickets: null,
                    numOfTicsForEvent: null,
                    eventImgSize: MediaQuery.of(context).size.width - 16,
                    eventDescHeight: 120.0,
                  )
                : EventBlock(
                    event: event,
                    shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                    viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                    viewEventTickets: null,
                    numOfTicsForEvent: null,
                    eventImgSize: MediaQuery.of(context).size.width - 16,
                    eventDescHeight: 120.0,
                  ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    eventsScrollController = ScrollController();
    eventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * eventsScrollController.position.maxScrollExtent;
      if (eventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalEvents();
      }
    });
    getEvents();
  }

  @override
  void dispose() {
    super.dispose();
    eventsScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        elevation: 0.5,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Fonts().textW700(
          "Virtual Events",
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
                onPressed: () => showEventPreferenceDialog(),
                icon: Icon(
                  FontAwesomeIcons.slidersH,
                  size: 20.0,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => PageTransitionService(
                  context: context,
                ).transitionToCreateEventPage(),
                icon: Icon(
                  FontAwesomeIcons.plus,
                  size: 20.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => PageTransitionService(
                  context: context,
                  currentUser: widget.currentUser,
                  areaName: "",
                ).transitionToSearchPage(),
                child: SearchTile(),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(35.0),
        ));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar,
        body: Container(
          key: PageStorageKey('key0'),
          color: Colors.white,
          child: isLoading
              ? LoadingScreen(
                  context: context,
                  loadingDescription: 'Loading Events...',
                )
              : eventResults.isEmpty
                  ? Column(
                      children: <Widget>[
                        SizedBox(height: 32.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width - 16,
                              ),
                              child: CustomText(
                                context: context,
                                text: "We Could Not Find Any Events According to Your Preferences",
                                textColor: Colors.black,
                                textAlign: TextAlign.center,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => showEventPreferenceDialog(),
                              child: CustomText(
                                context: context,
                                text: "Change My Preferences",
                                textColor: Colors.blueAccent,
                                textAlign: TextAlign.center,
                                underline: false,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : listEvents(),
        ),
      ),
    );
  }
}
