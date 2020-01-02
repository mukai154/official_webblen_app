import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase_data/calendar_event_data.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_appbar.dart';

import 'create_edit_reminder_page.dart';

class ReminderPage extends StatefulWidget {
  final CalendarEvent event;
  final WebblenUser currentUser;
  ReminderPage({this.event, this.currentUser});

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  Widget eventCaption() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Fonts().textW700(widget.event.title, 24.0, Colors.black, TextAlign.left),
          Fonts().textW400(widget.event.description, 16.0, Colors.black, TextAlign.left),
        ],
      ),
    );
  }

  Widget eventDate() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
      child: Fonts().textW400(widget.event.dateTime, 12.0, FlatColors.darkGray, TextAlign.left),
    );
  }

  void editEventAction() {
    Navigator.of(context).pop();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CreateEditReminderPage(currentUser: widget.currentUser, preSelectedEvent: widget.event)));
  }

  void deleteEventAction() {
    ShowAlertDialogService().showLoadingDialog(context);
    CalendarEventDataService().deleteEvent(widget.currentUser.uid, widget.event.key).then((error) {
      Navigator.of(context).pop();
      ShowAlertDialogService().showActionSuccessDialog(context, "Reminder Deleted!", "This reminder is no longer in your calendar.", () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    });
  }

  showOptions() {
    ShowAlertDialogService().showCalendarEventOptions(context, () => editEventAction(), () => deleteEventAction());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget eventView() {
      return Container(
        color: Colors.white,
        child: ListView(children: <Widget>[
          eventDate(),
          eventCaption(),
        ]),
      );
    }

    return Scaffold(
      appBar: WebblenAppBar()
          .actionAppBar("Reminder", IconButton(icon: Icon(FontAwesomeIcons.ellipsisH, size: 18.0, color: Colors.black), onPressed: () => showOptions())),
      body: eventView(),
    );
  }
}
