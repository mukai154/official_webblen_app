import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:webblen/models/event.dart';
import 'time_calc.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:flutter/material.dart';

class DeviceCalendar {

  addEventToCalendar(BuildContext context, Event event){
    DeviceCalendarEvent calEvent = DeviceCalendarEvent(
      title: event.title,
      description: event.description,
      location: event.address,
      startDate: TimeCalc().getDateTimeFromMilliseconds(event.startDateInMilliseconds),
      endDate: TimeCalc().getDateTimeFromMilliseconds(event.endDateInMilliseconds),
      allDay: false,
    );
    Add2Calendar.addEvent2Cal(calEvent).then((success) {
      if (success){
        ShowAlertDialogService().showSuccessDialog(context, "Event Added to Calendar!", "${event.title} has been added to your calendar");
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Error!", "There was an issue adding this event to your calendar");
      }
    });
  }

}