List<String> timeListFromSelectedTime(String selectedTime) {
  int index = timeList.indexOf(selectedTime);
  List<String> newList = selectedTime == "11:30 PM" ? ['11:30 PM', '11:59 PM'] : timeList.sublist(index, timeList.length);
  return newList;
}

String? getCurrentTimezone() {
  DateTime currentDateTime = DateTime.now();
  DateTime daylightSavingsBegin = DateTime(DateTime.now().year, 3, 14);
  DateTime daylightSavingsEnd = DateTime(DateTime.now().year, 11, 7);
  double offset = (DateTime.now().timeZoneOffset.inMinutes / 60).toDouble();

  //account for daylight savings
  if (currentDateTime.isAfter(daylightSavingsBegin) && currentDateTime.isBefore(daylightSavingsEnd)) {
    offset -= 1;
  }

  String? timezone = timezones.firstWhere((timezone) => timezone['offset'] == offset)['abbr'];
  return timezone;
}

final List<String> timeList = [
  '12:00 AM',
  '12:30 AM',
  '1:00 AM',
  '1:30 AM',
  '2:00 AM',
  '2:30 AM',
  '3:00 AM',
  '3:30 AM',
  '4:00 AM',
  '4:30 AM',
  '5:00 AM',
  '5:30 AM',
  '6:00 AM',
  '6:30 AM',
  '7:00 AM',
  '7:30 AM',
  '8:00 AM',
  '8:30 AM',
  '9:00 AM',
  '9:30 AM',
  '10:00 AM',
  '10:30 AM',
  '11:00 AM',
  '11:30 AM',
  '12:00 PM',
  '12:30 PM',
  '1:00 PM',
  '1:30 PM',
  '2:00 PM',
  '2:30 PM',
  '3:00 PM',
  '3:30 PM',
  '4:00 PM',
  '4:30 PM',
  '5:00 PM',
  '5:30 PM',
  '6:00 PM',
  '6:30 PM',
  '7:00 PM',
  '7:30 PM',
  '8:00 PM',
  '8:30 PM',
  '9:00 PM',
  '9:30 PM',
  '10:00 PM',
  '10:30 PM',
  '11:00 PM',
  '11:30 PM',
];

final List<Map<String, dynamic>> timezones = [
  {
    "value": "Samoa Standard Time",
    "abbr": "SST",
    "offset": -13,
    "text": "(UTC-13:00) Pacific/Apia",
  },
  {
    "value": "Dateline Standard Time",
    "abbr": "DST",
    "offset": -12,
    "text": "(UTC-12:00) Etc/GMT+12",
  },
  {
    "value": "UTC-11",
    "abbr": "UTC-11",
    "offset": -11,
    "text": "(UTC-11:00) Pacific/Midway",
  },
  {
    "value": "Hawaiian Standard Time",
    "abbr": "HST",
    "offset": -10,
    "text": "(UTC-10:00) Pacific/Honolulu	",
  },
  {
    "value": "Alaskan Standard Time",
    "abbr": "AST",
    "offset": -9,
    "text": "(UTC-09:00) America/Anchorage",
  },
  {
    "value": "Pacific Standard Time",
    "abbr": "PST",
    "offset": -8,
    "text": "(UTC-08:00) America/Los_Angeles, America/Santa_Isabel",
  },
  {
    "value": "Mountain Standard Time",
    "abbr": "MST",
    "offset": -7,
    "text": "(UTC-07:00) America/Denver, America/Chihuahua, America/Phoenix",
  },
  {
    "value": "Central Standard Time",
    "abbr": "CST",
    "offset": -6,
    "text": "(UTC-06:00) America/Chicago, America/Regina, America/Guatemala",
  },
  {
    "value": "Eastern Standard Time",
    "abbr": "EST",
    "offset": -5,
    "text": "(UTC-05:00) America/Chicago, America/Indianapolis, America/Bogota",
  },
  {
    "value": "Venezuela Standard Time",
    "abbr": "VST",
    "offset": -4.5,
    "text": "(UTC-04:30) America/Caracas",
  },
  {
    "value": "Pacific SA Standard Time	",
    "abbr": "PSST",
    "offset": -4,
    "text": "(UTC-04:00) America/Santiago",
  },
  {
    "value": "Newfoundland Standard Time",
    "abbr": "NST",
    "offset": -3.5,
    "text": "(UTC-04:00) America/St_Johns",
  },
  {
    "value": "Bahia Standard Time",
    "abbr": "BST",
    "offset": -3,
    "text": "(UTC-03:00) America/Bahia, America/Buenos_Aires",
  },
  {
    "value": "Cape Verde Standard Time",
    "abbr": "CVST",
    "offset": -1,
    "text": "(UTC-01:00) Atlantic/Cape_Verde",
  },
  {
    "value": "GMT Standard Time	",
    "abbr": "GMT",
    "offset": 0,
    "text": "(UTC-00:00) Europe/London",
  },
  {
    "value": "Central Europe Standard Time",
    "abbr": "CEST",
    "offset": 1,
    "text": "(UTC+01:00) Europe/Budapest",
  },
  {
    "value": "GTB Standard Time",
    "abbr": "GTB",
    "offset": 2,
    "text": "(UTC+02:00) Europe/Bucharest",
  },
  {
    "value": "E. Africa Standard Time",
    "abbr": "EAST",
    "offset": 3,
    "text": "(UTC+03:00) Africa/Nairobi, Asia/Baghdad",
  },
  {
    "value": "Iran Standard Time",
    "abbr": "IST",
    "offset": 3.5,
    "text": "(UTC+03:30) Asia/Tehran",
  },
  {
    "value": "Georgian Standard Time",
    "abbr": "GST",
    "offset": 4,
    "text": "(UTC+04:00) Asia/Tbilisi",
  },
  {
    "value": "West Asia Standard Time",
    "abbr": "WAST",
    "offset": 5,
    "text": "(UTC+05:00) Asia/Tashkent",
  },
  {
    "value": "Sri Lanka Standard Time",
    "abbr": "SLST",
    "offset": 5.5,
    "text": "(UTC+05:30) Asia/Colombo",
  },
  {
    "value": "Central Asia Standard Time",
    "abbr": "CAST",
    "offset": 6,
    "text": "(UTC+06:00) Asia/Almaty",
  },
  {
    "value": "SE Asia Standard Time",
    "abbr": "SEAST",
    "offset": 7,
    "text": "(UTC+07:00) Asia/Bangkok",
  },
  {
    "value": "North Asia Standard Time",
    "abbr": "NAST",
    "offset": 8,
    "text": "(UTC+08:00) Asia/Shanghai",
  },
  {
    "value": "Tokyo Standard Time",
    "abbr": "TST",
    "offset": 9,
    "text": "(UTC+09:00) Asia/Tokyo",
  },
  {
    "value": "Korea Standard Time",
    "abbr": "KST",
    "offset": 9,
    "text": "(UTC+09:00) Asia/Seoul",
  },
  {
    "value": "AUS Central Standard Time",
    "abbr": "AUS",
    "offset": 9.5,
    "text": "(UTC+09:30) Australia/Darwin",
  },
  {
    "value": "West Pacific Standard Time",
    "abbr": "WPST",
    "offset": 10,
    "text": "(UTC+10:00) Pacific/Port Moresby",
  },
  {
    "value": "Central Pacific Standard Time",
    "abbr": "CPST",
    "offset": 11,
    "text": "(UTC+11:00) Pacific/Guadalcanal",
  },
  {
    "value": "New Zealand Standard Time",
    "abbr": "NZST",
    "offset": 12,
    "text": "(UTC+12:00) Pacific/Auckland",
  },
  {
    "value": "Line Islands Standard Time	",
    "abbr": "LIST",
    "offset": 14,
    "text": "(UTC+14:00) Pacific/Kiritimati",
  },
];
