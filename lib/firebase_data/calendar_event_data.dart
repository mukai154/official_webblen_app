import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/models/calendar_event.dart';

class CalendarEventDataService {
  final CollectionReference calendarEventsRef = Firestore.instance.collection("user_calendars");

  //***CREATE
  Future<String> saveEvent(String uid, CalendarEvent calendarEvent) async {
    String error = '';
    await calendarEventsRef.document(uid).collection('events').document(calendarEvent.key).setData(calendarEvent.toMap()).then((res) {}).catchError((e) {
      error = e.details;
    });
    return error;
  }

  //***READ
  Future<bool> checkIfCalendarEventExists(String uid, String key) async {
    bool eventExists = false;
    await calendarEventsRef.document(uid).collection("events").document(key).get().then((res) {
      if (res.exists) {
        eventExists = true;
      }
    });
    return eventExists;
  }

  Future<List<CalendarEvent>> getUserCalendarEvents(String uid) async {
    List<CalendarEvent> calendarEvents = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserCalendarEvents');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> map = Map<String, dynamic>.from(resultMap);
        CalendarEvent result = CalendarEvent.fromMap(map);
        calendarEvents.add(result);
      });
    }
    return calendarEvents;
  }

  //**UPDATE
  Future<String> updateEvent(String uid, CalendarEvent calendarEvent) async {
    String error = "";
    await calendarEventsRef.document(uid).collection("events").document(calendarEvent.key).updateData(calendarEvent.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  //***DELETE
  Future<String> deleteEvent(String uid, String key) async {
    String error = "";
    await calendarEventsRef.document(uid).collection("events").document(key).delete().catchError((e) {
      error = e.details;
    });
    return error;
  }
}
