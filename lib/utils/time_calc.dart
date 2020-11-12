import 'package:intl/intl.dart';

class TimeCalc {
  DateTime currentDateTime = DateTime.now();
  DateFormat dateFormatter = DateFormat("MM/dd/yyyy");
  DateFormat timeFormatter = DateFormat("h:mm a");
  DateFormat dateTimeFormatter = DateFormat("MM/dd/yyyy h:mm a");
  DateFormat formatter = DateFormat('MMM dd, yyyy');

  String getStringFromDate(DateTime data) {
    String dateTime = formatter.format(data);
    print(dateTime);
    return dateTime;
  }

  DateTime getDateTimeFromString(String data) {
    DateTime dateTime = formatter.parse(data);
    print(dateTime);
    return dateTime;
  }

  getTimeDifferenceInMinutes(String endTime) {
    String difference = "1 hour";
    String formattedTime = timeFormatter.format(currentDateTime);
    int time1 = timeFormatter.parse(formattedTime).millisecondsSinceEpoch;
    int time2 = timeFormatter.parse(endTime).millisecondsSinceEpoch;
    int timeDifference = ((time2 - time1) / 600000).round();

    if (timeDifference > 59) {
      int hours = (timeDifference / 60).round();
      int remainingMinutes = timeDifference - (hours * 60);
      difference = "$hours hour(s) $remainingMinutes";
    } else {
      difference = "$timeDifference";
    }

    return difference;
  }

  String showTimeRemaining(int endTimeInMilliseconds) {
    String timeRemaining;
    DateTime givenTime = DateTime.fromMillisecondsSinceEpoch(endTimeInMilliseconds);
    int timeDifferenceInMinutes = givenTime.difference(currentDateTime).inMinutes;
    if (timeDifferenceInMinutes >= 60) {
      int hoursLeft = (timeDifferenceInMinutes / 60).round();
      int daysLeft = (hoursLeft / 24).round();
      int minutesLeft = timeDifferenceInMinutes - (hoursLeft * 60);
      if (hoursLeft >= 24) {
        hoursLeft = (hoursLeft - daysLeft * 24).round();
        timeRemaining = daysLeft == 1 ? "$daysLeft day $hoursLeft hours and $minutesLeft minutes" : "$daysLeft days $hoursLeft hours and $minutesLeft minutes";
      } else {
        timeRemaining = "$hoursLeft hour and $minutesLeft minutes";
      }
    } else {
      timeRemaining = "$timeDifferenceInMinutes minutes";
    }

    return timeRemaining;
  }

  String getPastTimeFromMilliseconds(int timeInMilliseconds) {
    String timeDetail;
    int hours = 0;
    DateTime givenTime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    int timeDifferenceInMinutes = currentDateTime.difference(givenTime).inMinutes;
    if (timeDifferenceInMinutes >= 60) {
      hours = (timeDifferenceInMinutes / 60).round();
    }
    if (hours >= 1) {
      if (hours >= 24 && hours < 48) {
        timeDetail = "yesterday";
      } else if (hours >= 48) {
        int days = (hours / 24).round();
        timeDetail = "$days days ago";
        if (days > 3) {
          timeDetail = DateFormat('MMM dd, h:mm a').format(givenTime);
        }
      } else {
        timeDetail = "$hours hours ago";
      }
    } else {
      timeDetail = "$timeDifferenceInMinutes minutes ago";
    }
    return timeDetail;
  }

  DateTime getDateTimeFromMilliseconds(int startDateInMilliseconds) {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(startDateInMilliseconds);
    return dateTime;
  }

  String getWhenEventIsHappening(int eventStartInMilliseconds, int eventEndInMilliseconds, String eventStartTime) {
    String eventTime = '';
    DateFormat dateFormat = DateFormat("MMM d  h:mma");
    DateTime eventDateTime = DateTime.fromMillisecondsSinceEpoch(eventStartInMilliseconds);
    DateTime currentDateTime = DateTime.now();
    int currentDateTimeInMilliseconds = currentDateTime.millisecondsSinceEpoch;

    if (eventStartInMilliseconds - currentDateTimeInMilliseconds <= 86400000 && eventStartInMilliseconds > currentDateTimeInMilliseconds) {
      if (eventDateTime.weekday == currentDateTime.weekday) {
        if (eventStartInMilliseconds - currentDateTimeInMilliseconds <= 1800000) {
          eventTime = 'Starting Soon...';
        } else {
          eventTime = 'Today at $eventStartTime';
        }
      } else {
        eventTime = 'Tomorrow at $eventStartTime';
      }
    } else if (eventDateTime.difference(currentDateTime) > Duration(days: 1) &&
        eventDateTime.difference(currentDateTime) < Duration(days: 2) &&
        eventDateTime.weekday == currentDateTime.weekday + 1) {
      eventTime = 'Tomorrow at $eventStartTime';
    } else if (currentDateTimeInMilliseconds >= eventStartInMilliseconds && currentDateTimeInMilliseconds <= eventEndInMilliseconds) {
      eventTime = 'Happening Now!';
    } else {
      eventTime = dateFormat.format(eventDateTime);
    }

    return eventTime;
  }
}
