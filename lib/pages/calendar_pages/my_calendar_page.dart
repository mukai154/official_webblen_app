import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase_data/calendar_event_data.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_calendar/calendar_event_row.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

import 'create_edit_reminder_page.dart';

class MyCalendarPage extends StatefulWidget {
  final WebblenUser currentUser;

  MyCalendarPage({
    this.currentUser,
  });

  @override
  _MyCalendarPageState createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  CalendarController calendarController = CalendarController();
  Map<DateTime, List> allEvents = {};
  String filter = "all";
  //String filter = "tst";

  List _selectedEvents = [];
  AnimationController _animationController;
  CalendarController _calendarController;

  transitionToNewEventPage(CalendarEvent selectedEvent) async {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      uid: widget.currentUser.uid,
      action: 'newEvent',
    ).transitionToMyCommunitiesPage();
  }

  transitionToNewReminderPage(CalendarEvent selectedEvent) async {
    Navigator.of(context).pop();
    CalendarEvent event = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditReminderPage(
          currentUser: widget.currentUser,
          preSelectedEvent: selectedEvent,
          preSelectedDateTime: calendarController.selectedDay,
        ),
      ),
    );
    if (event != null) {
      final _selectedDay = DateTime.now();
      DateTime eventDateTime = Time().getDateTimeFromString(event.dateTime);
      DateTime eventDay = DateTime(
        eventDateTime.year,
        eventDateTime.month,
        eventDateTime.day,
      );
      if (allEvents[eventDay] == null) {
        allEvents[eventDay] = [];
      }
      List eventsOnDay = allEvents[eventDay].toList(
        growable: true,
      );
      eventsOnDay.add(event);
      if (eventDateTime.day == _selectedDay.day && eventDateTime.month == _selectedDay.month && eventDateTime.year == _selectedDay.year) {
        _selectedEvents.add(event);
      }
      allEvents[eventDay] = eventsOnDay;
      setState(() {});
    }
  }

  transitionToEventDetailsPage(CalendarEvent event) async {
    ShowAlertDialogService().showLoadingDialog(context);
    if (event.type == 'reminder') {
      Navigator.of(context).pop();
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        calendarEvent: event,
        eventIsLive: false,
      ).transitionToReminderPage();
    } else {
      WebblenEvent webblenEvent = await EventDataService().getEvent(event.key);
      Navigator.of(context).pop();
      if (webblenEvent != null) {
        PageTransitionService(
          context: context,
          currentUser: widget.currentUser,
          eventID: webblenEvent.id,
          eventIsLive: false,
        ).transitionToEventPage();
      } else {
        ShowAlertDialogService().showFailureDialog(
          context,
          "Uh Oh",
          "There was issue loading this event. Please try again later",
        );
      }
    }
  }

  filterEvents(String newFilter) {
    isLoading = true;
    filter = newFilter;
    _selectedEvents = [];
    allEvents = {};
    setState(() {});
    final _selectedDay = DateTime.now();
    CalendarEventDataService().getUserCalendarEvents(widget.currentUser.uid).then((res) {
      res.forEach((event) {
        if (filter == 'all' || filter == event.type) {
          DateTime eventDateTime = Time().getDateTimeFromString(event.dateTime);
          if (DateTime.now().difference(eventDateTime) < Duration(hours: 12)) {
            DateTime eventDay = DateTime(
              eventDateTime.year,
              eventDateTime.month,
              eventDateTime.day,
            );
            if (allEvents[eventDay] == null) {
              allEvents[eventDay] = [];
            }
            List eventsOnDay = allEvents[eventDay].toList(
              growable: true,
            );
            eventsOnDay.add(event);
            if (eventDateTime.day == _selectedDay.day && eventDateTime.month == _selectedDay.month && eventDateTime.year == _selectedDay.year) {
              _selectedEvents.add(event);
            }
            allEvents[eventDay] = eventsOnDay;
          } else {
            CalendarEventDataService().deleteEvent(
              widget.currentUser.uid,
              event.key,
            );
          }
        }
      });
      isLoading = false;
      setState(() {});
    });
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      initialCalendarFormat: CalendarFormat.twoWeeks,
      events: allEvents,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        selectedColor: FlatColors.webblenRed,
        todayColor: Colors.black12,
        markersColor: FlatColors.darkGray,
        markersMaxAmount: 4,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        centerHeaderTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w700,
          fontSize: 18.0,
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CalendarEventRow(
          event: _selectedEvents[index],
          onTapAction: () => transitionToEventDetailsPage(_selectedEvents[index]),
        );
      },
      itemCount: _selectedEvents.length,
    );
  }

  void _onDaySelected(DateTime day, List events) {
    _selectedEvents = events;
    setState(() {});
  }

  void _onVisibleDaysChanged(
    DateTime first,
    DateTime last,
    CalendarFormat format,
  ) {}

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 400,
      ),
    );
    _animationController.forward();
    filterEvents('all');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: Scaffold(
        appBar: WebblenAppBar().actionAppBar(
          "Calendar",
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.slidersH,
                  color: Colors.black,
                  size: 18.0,
                ),
                onPressed: () => ShowAlertDialogService().showCalendarFilterDialog(
                  context,
                  filter,
                  () => filterEvents("all"),
                  () => filterEvents("saved"),
                  () => filterEvents("created"),
                  () => filterEvents("reminder"),
                ),
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.edit,
                  color: Colors.black,
                  size: 18.0,
                ),
                onPressed: () => ShowAlertDialogService().showCreateEventReminderDialog(
                  context,
                  () => transitionToNewEventPage(null),
                  () => transitionToNewReminderPage(null),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                  height: 24.0,
                  width: MediaQuery.of(context).size.width,
                  color: FlatColors.iosOffWhite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Fonts().textW500(
                        filter == 'all' ? 'All Events' : filter == 'saved' ? 'Saved Events' : filter == 'created' ? 'Created Events' : 'Reminders',
                        14.0,
                        Colors.black54,
                        TextAlign.center,
                      ),
                    ],
                  )),
              Divider(
                height: 2.0,
                thickness: 0,
                color: Colors.black12,
              ),
              isLoading
                  ? LoadingScreen(
                      context: context,
                    )
                  : _buildTableCalendar(),
              // _buildTableCalendarWithBuilders(),
              const SizedBox(
                height: 8.0,
              ),
              //_buildButtons(),
              const SizedBox(
                height: 8.0,
              ),
              Expanded(
                child: _buildEventList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
