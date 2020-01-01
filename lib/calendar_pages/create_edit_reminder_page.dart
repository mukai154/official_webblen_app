import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/firebase_data/calender_event_data.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/widgets_common/common_appbar.dart';

class CreateEditReminderPage extends StatefulWidget {
  final WebblenUser currentUser;
  final CalendarEvent preSelectedEvent;
  final DateTime preSelectedDateTime;

  CreateEditReminderPage({this.currentUser, this.preSelectedEvent, this.preSelectedDateTime});

  @override
  _CreateEditReminderPageState createState() => _CreateEditReminderPageState();
}

class _CreateEditReminderPageState extends State<CreateEditReminderPage> {
  CalendarEvent newCalendarEvent = CalendarEvent();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  DateFormat formatter = DateFormat('MMM dd, yyyy | h:mm a');
  DateTime selectedDateTime;
  DateTime preDateTime;

  void handleNewDate(DateTime result) async {
    selectedDateTime = result;
    if (selectedDateTime.hour == 0 || selectedDateTime.hour == 12) {
      selectedDateTime = selectedDateTime.add(Duration(hours: 12));
    }
    ScaffoldState scaffold = scaffoldKey.currentState;
    DateTime today = DateTime.now().subtract(Duration(hours: 1));
    if (selectedDateTime.isBefore(today)) {
      scaffold.showSnackBar(SnackBar(
        content: Text("Invalid Date"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else {
      newCalendarEvent.dateTime = formatter.format(selectedDateTime);
      setState(() {});
    }
  }

  showPickerDateTime(BuildContext context) {
    Picker(
      adapter: new DateTimePickerAdapter(
        customColumnType: [1, 2, 0, 7, 4, 6],
        isNumberMonth: false,
        yearBegin: DateTime.now().year,
        yearEnd: DateTime.now().year + 6,
      ),
      onConfirm: (Picker picker, List value) {
        DateTime selectedDate = (picker.adapter as DateTimePickerAdapter).value;
        handleNewDate(selectedDate);
      },
    ).show(scaffoldKey.currentState);
  }

  Widget _buildTitleField() {
    return Container(
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TextFormField(
            initialValue: newCalendarEvent.title != null && newCalendarEvent.title.isNotEmpty ? newCalendarEvent.title : "",
            decoration: InputDecoration(
              hintText: "Title",
              contentPadding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
              border: InputBorder.none,
            ),
            onSaved: (value) => newCalendarEvent.title = value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: "Helvetica Neue",
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            textInputAction: TextInputAction.done,
            autocorrect: false,
          ),
        ));
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 180,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 16),
      decoration: BoxDecoration(
        color: FlatColors.textFieldGray,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: TextFormField(
          initialValue: newCalendarEvent.description != null && newCalendarEvent.description.isNotEmpty ? newCalendarEvent.description : "",
          decoration: InputDecoration(
            hintText: "Description",
            contentPadding: EdgeInsets.all(8),
            border: InputBorder.none,
          ),
          onSaved: (val) => newCalendarEvent.description = val,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: "Helvetica Neue",
          ),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          autocorrect: false,
        ),
      ),
    );
  }

  saveAndSubmit() async {
    ShowAlertDialogService().showLoadingDialog(context);
    final form = formKey.currentState;
    form.save();
    ScaffoldState scaffold = scaffoldKey.currentState;
    if (selectedDateTime.isBefore(DateTime.now()) && widget.preSelectedEvent == null) {
      Navigator.of(context).pop();
      scaffold.showSnackBar(SnackBar(
        content: Text("Invalid Date"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else if (newCalendarEvent.title == null || newCalendarEvent.title.isEmpty) {
      Navigator.of(context).pop();
      scaffold.showSnackBar(SnackBar(
        content: Text("Please Set a Title"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else if (newCalendarEvent.description == null || newCalendarEvent.description.isEmpty) {
      Navigator.of(context).pop();
      scaffold.showSnackBar(SnackBar(
        content: Text("Please Set a Description"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else {
      newCalendarEvent.timezone = await FlutterNativeTimezone.getLocalTimezone();
      if (widget.preSelectedEvent == null) {
        newCalendarEvent.key = randomAlphaNumeric(16);
      }
      newCalendarEvent.type = 'reminder';
      CalendarEventDataService().saveEvent(widget.currentUser.uid, newCalendarEvent).then((error) {
        if (error.isEmpty) {
          CreateNotification()
              .createTimedNotification(randomBetween(0, 99), selectedDateTime.millisecondsSinceEpoch, newCalendarEvent.title, newCalendarEvent.description, '');
          Navigator.of(context).pop();
          Navigator.pop(context, newCalendarEvent);
        } else {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime dateTime = DateTime.now().add(Duration(hours: 1));
    preDateTime = dateTime.subtract(Duration(minutes: dateTime.minute));
    if (widget.preSelectedEvent != null) {
      newCalendarEvent = widget.preSelectedEvent;
      selectedDateTime = Time().getDateTimeFromString(newCalendarEvent.dateTime);
    } else {
      selectedDateTime = preDateTime;
      newCalendarEvent.dateTime = formatter.format(preDateTime);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        key: scaffoldKey,
        appBar: WebblenAppBar().actionAppBar(
          widget.preSelectedEvent != null ? "Edit Reminder" : "New Reminder",
          Padding(
            padding: EdgeInsets.only(top: 18.0, right: 16.0),
            child: GestureDetector(
              onTap: () => saveAndSubmit(),
              child: Fonts().textW700("Save", 18.0, Colors.black, TextAlign.right),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        child: Fonts().textW700("Date & Time", 20.0, FlatColors.darkGray, TextAlign.left),
                      ),
                      SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () => showPickerDateTime(context),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child: newCalendarEvent.dateTime == null
                              ? Fonts().textW500(formatter.format(preDateTime), 18.0, Colors.blue, TextAlign.left)
                              : Fonts().textW500(newCalendarEvent.dateTime, 18.0, FlatColors.electronBlue, TextAlign.left),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _buildTitleField(),
                      SizedBox(height: 8.0),
                      _buildDescriptionField(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
