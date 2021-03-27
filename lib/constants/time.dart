List<String> timeListFromSelectedTime(String selectedTime) {
  int index = timeList.indexOf(selectedTime);
  List<String> newList = selectedTime == "11:30 PM" ? ['11:30 PM', '11:59 PM'] : timeList.sublist(index, timeList.length);
  return newList;
}

String getCurrentTimezone() {
  print(DateTime.now().timeZoneName);
  double offset = (DateTime.now().timeZoneOffset.inMinutes / 60).toDouble();
  String timezone = timezones.firstWhere((timezone) => timezone['offset'] == offset)['abbr'];
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
    "value": "Paraguay Standard Time",
    "abbr": "PYT",
    "offset": -4,
    "isdst": false,
    "text": "(UTC-04:00) Asuncion",
    "utc": ["America/Asuncion"]
  },
  {
    "value": "Atlantic Standard Time",
    "abbr": "ADT",
    "offset": -3,
    "isdst": true,
    "text": "(UTC-04:00) Atlantic Time (Canada)",
    "utc": ["America/Glace_Bay", "America/Goose_Bay", "America/Halifax", "America/Moncton", "America/Thule", "Atlantic/Bermuda"]
  },
  {
    "value": "Central Brazilian Standard Time",
    "abbr": "CBST",
    "offset": -4,
    "isdst": false,
    "text": "(UTC-04:00) Cuiaba",
    "utc": ["America/Campo_Grande", "America/Cuiaba"]
  },
  {
    "value": "SA Western Standard Time",
    "abbr": "SWST",
    "offset": -4,
    "isdst": false,
    "text": "(UTC-04:00) Georgetown, La Paz, Manaus, San Juan",
    "utc": [
      "America/Anguilla",
      "America/Antigua",
      "America/Aruba",
      "America/Barbados",
      "America/Blanc-Sablon",
      "America/Boa_Vista",
      "America/Curacao",
      "America/Dominica",
      "America/Grand_Turk",
      "America/Grenada",
      "America/Guadeloupe",
      "America/Guyana",
      "America/Kralendijk",
      "America/La_Paz",
      "America/Lower_Princes",
      "America/Manaus",
      "America/Marigot",
      "America/Martinique",
      "America/Montserrat",
      "America/Port_of_Spain",
      "America/Porto_Velho",
      "America/Puerto_Rico",
      "America/Santo_Domingo",
      "America/St_Barthelemy",
      "America/St_Kitts",
      "America/St_Lucia",
      "America/St_Thomas",
      "America/St_Vincent",
      "America/Tortola",
      "Etc/GMT+4"
    ]
  },
  {
    "value": "Newfoundland Standard Time",
    "abbr": "NST",
    "offset": -2.5,
    "isdst": true,
    "text": "(UTC-03:30) Newfoundland",
    "utc": ["America/St_Johns"]
  },
  {
    "value": "E. South America Standard Time",
    "abbr": "ESAST",
    "offset": -3,
    "isdst": false,
    "text": "(UTC-03:00) Brasilia, Argentina",
    "utc": ["America/Sao_Paulo"]
  },
  {
    "value": "SA Eastern Standard Time",
    "abbr": "SEST",
    "offset": -3,
    "isdst": false,
    "text": "(UTC-03:00) Cayenne, Fortaleza",
    "utc": [
      "America/Araguaina",
      "America/Belem",
      "America/Cayenne",
      "America/Fortaleza",
      "America/Maceio",
      "America/Paramaribo",
      "America/Recife",
      "America/Santarem",
      "Antarctica/Rothera",
      "Atlantic/Stanley",
      "Etc/GMT+3"
    ]
  },
  {
    "value": "Greenland/Montevideo Standard Time",
    "abbr": "GST/MST",
    "offset": -3,
    "isdst": true,
    "text": "(UTC-03:00) Greenland, Montevideo",
    "utc": ["America/Godthab"]
  },
  {
    "value": "Bahia Standard Time",
    "abbr": "BST",
    "offset": -3,
    "isdst": false,
    "text": "(UTC-03:00) Salvador",
    "utc": ["America/Bahia"]
  },
  {
    "value": "Cape/Azores Verde Standard Time",
    "abbr": "CVST/AST",
    "offset": -1,
    "isdst": false,
    "text": "(UTC-01:00) Cape Verde Is., Azores",
    "utc": ["Atlantic/Cape_Verde", "Etc/GMT+1"]
  },
  {
    "value": "Morocco Standard Time",
    "abbr": "MST",
    "offset": 1,
    "isdst": true,
    "text": "(UTC) Casablanca",
    "utc": ["Africa/Casablanca", "Africa/El_Aaiun"]
  },
  {
    "value": "UTC",
    "abbr": "UTC",
    "offset": 0,
    "isdst": false,
    "text": "(UTC) Coordinated Universal Time",
    "utc": ["America/Danmarkshavn", "Etc/GMT"]
  },
  {
    "value": "GMT Standard Time",
    "abbr": "GMT",
    "offset": 0,
    "isdst": false,
    "text": "(UTC) Edinburgh, London",
    "utc": ["Europe/Isle_of_Man", "Europe/Guernsey", "Europe/Jersey", "Europe/London"]
  },
  {
    "value": "GDT Standard Time",
    "abbr": "GDT",
    "offset": 1,
    "isdst": true,
    "text": "(UTC) Dublin, Lisbon, London",
    "utc": ["Atlantic/Canary", "Atlantic/Faeroe", "Atlantic/Madeira", "Europe/Dublin", "Europe/Lisbon"]
  },
  {
    "value": "Greenwich Standard Time",
    "abbr": "GST",
    "offset": 0,
    "isdst": false,
    "text": "(UTC) Monrovia, Reykjavik",
    "utc": [
      "Africa/Abidjan",
      "Africa/Accra",
      "Africa/Bamako",
      "Africa/Banjul",
      "Africa/Bissau",
      "Africa/Conakry",
      "Africa/Dakar",
      "Africa/Freetown",
      "Africa/Lome",
      "Africa/Monrovia",
      "Africa/Nouakchott",
      "Africa/Ouagadougou",
      "Africa/Sao_Tome",
      "Atlantic/Reykjavik",
      "Atlantic/St_Helena"
    ]
  },
  {
    "value": "W. Europe Standard Time",
    "abbr": "WEST",
    "offset": 2,
    "isdst": true,
    "text": "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna",
    "utc": [
      "Arctic/Longyearbyen",
      "Europe/Amsterdam",
      "Europe/Andorra",
      "Europe/Berlin",
      "Europe/Busingen",
      "Europe/Gibraltar",
      "Europe/Luxembourg",
      "Europe/Malta",
      "Europe/Monaco",
      "Europe/Oslo",
      "Europe/Rome",
      "Europe/San_Marino",
      "Europe/Stockholm",
      "Europe/Vaduz",
      "Europe/Vatican",
      "Europe/Vienna",
      "Europe/Zurich"
    ]
  },
  {
    "value": "Romance Standard Time",
    "abbr": "RST",
    "offset": 2,
    "isdst": true,
    "text": "(UTC+01:00) Brussels, Copenhagen, Madrid, Paris",
    "utc": ["Africa/Ceuta", "Europe/Brussels", "Europe/Copenhagen", "Europe/Madrid", "Europe/Paris"]
  },
  {
    "value": "Central European Standard Time",
    "abbr": "CEDT",
    "offset": 2,
    "isdst": true,
    "text": "(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb",
    "utc": ["Europe/Sarajevo", "Europe/Skopje", "Europe/Warsaw", "Europe/Zagreb"]
  },
  {
    "value": "W. Central Africa Standard Time",
    "abbr": "WCAST",
    "offset": 1,
    "isdst": false,
    "text": "(UTC+01:00) West Central Africa",
    "utc": [
      "Africa/Algiers",
      "Africa/Bangui",
      "Africa/Brazzaville",
      "Africa/Douala",
      "Africa/Kinshasa",
      "Africa/Lagos",
      "Africa/Libreville",
      "Africa/Luanda",
      "Africa/Malabo",
      "Africa/Ndjamena",
      "Africa/Niamey",
      "Africa/Porto-Novo",
      "Africa/Tunis",
      "Etc/GMT-1"
    ]
  },
  {
    "value": "Namibia Standard Time",
    "abbr": "NST",
    "offset": 1,
    "isdst": false,
    "text": "(UTC+01:00) Windhoek",
    "utc": ["Africa/Windhoek"]
  },
  {
    "value": "GTB Standard Time",
    "abbr": "GTB",
    "offset": 3,
    "isdst": true,
    "text": "(UTC+02:00) Athens, Bucharest",
    "utc": ["Asia/Nicosia", "Europe/Athens", "Europe/Bucharest", "Europe/Chisinau"]
  },
  {
    "value": "Middle East Standard Time",
    "abbr": "MEST",
    "offset": 3,
    "isdst": true,
    "text": "(UTC+02:00) Beirut",
    "utc": ["Asia/Beirut"]
  },
  {
    "value": "Syria Standard Time",
    "abbr": "SDT",
    "offset": 3,
    "isdst": true,
    "text": "(UTC+02:00) Damascus",
    "utc": ["Asia/Damascus"]
  },
  {
    "value": "E. Europe Standard Time",
    "abbr": "EEDT",
    "offset": 3,
    "isdst": true,
    "text": "(UTC+02:00) E. Europe",
    "utc": [
      "Asia/Nicosia",
      "Europe/Athens",
      "Europe/Bucharest",
      "Europe/Chisinau",
      "Europe/Helsinki",
      "Europe/Kiev",
      "Europe/Mariehamn",
      "Europe/Nicosia",
      "Europe/Riga",
      "Europe/Sofia",
      "Europe/Tallinn",
      "Europe/Uzhgorod",
      "Europe/Vilnius",
      "Europe/Zaporozhye"
    ]
  },
  {
    "value": "South Africa Standard Time",
    "abbr": "SAST",
    "offset": 2,
    "isdst": false,
    "text": "(UTC+02:00) Harare, Pretoria",
    "utc": [
      "Africa/Blantyre",
      "Africa/Bujumbura",
      "Africa/Gaborone",
      "Africa/Harare",
      "Africa/Johannesburg",
      "Africa/Kigali",
      "Africa/Lubumbashi",
      "Africa/Lusaka",
      "Africa/Maputo",
      "Africa/Maseru",
      "Africa/Mbabane",
      "Etc/GMT-2"
    ]
  },
  {
    "value": "FLE Standard Time",
    "abbr": "FDT",
    "offset": 3,
    "isdst": true,
    "text": "(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius",
    "utc": [
      "Europe/Helsinki",
      "Europe/Kiev",
      "Europe/Mariehamn",
      "Europe/Riga",
      "Europe/Sofia",
      "Europe/Tallinn",
      "Europe/Uzhgorod",
      "Europe/Vilnius",
      "Europe/Zaporozhye"
    ]
  },
  {
    "value": "Turkey Standard Time",
    "abbr": "TDT",
    "offset": 3,
    "isdst": false,
    "text": "(UTC+03:00) Istanbul",
    "utc": ["Europe/Istanbul"]
  },
  {
    "value": "Israel Standard Time",
    "abbr": "JDT",
    "offset": 3,
    "isdst": true,
    "text": "(UTC+02:00) Jerusalem",
    "utc": ["Asia/Jerusalem"]
  },
  {
    "value": "Libya Standard Time",
    "abbr": "LST",
    "offset": 2,
    "isdst": false,
    "text": "(UTC+02:00) Tripoli",
    "utc": ["Africa/Tripoli"]
  },
  {
    "value": "Jordan/Arabic Standard Time",
    "abbr": "JST/AST",
    "offset": 3,
    "isdst": false,
    "text": "(UTC+03:00) Amman, Baghdad",
    "utc": ["Asia/Amman"]
  },
  {
    "value": "Kaliningrad Standard Time",
    "abbr": "KST",
    "offset": 3,
    "isdst": false,
    "text": "(UTC+02:00) Kaliningrad",
    "utc": ["Europe/Kaliningrad"]
  },
  {
    "value": "Arab/ E. Africa Standard Time",
    "abbr": "AST/EAST",
    "offset": 3,
    "isdst": false,
    "text": "(UTC+03:00) Kuwait, Riyadh, Nairobi",
    "utc": ["Asia/Aden", "Asia/Bahrain", "Asia/Kuwait", "Asia/Qatar", "Asia/Riyadh"]
  },
  {
    "value": "Moscow Standard Time",
    "abbr": "MSK",
    "offset": 3,
    "isdst": false,
    "text": "(UTC+03:00) Moscow, St. Petersburg, Volgograd, Minsk",
    "utc": ["Europe/Kirov", "Europe/Moscow", "Europe/Simferopol", "Europe/Volgograd", "Europe/Minsk"]
  },
  {
    "value": "Samara Time",
    "abbr": "SAMT",
    "offset": 4,
    "isdst": false,
    "text": "(UTC+04:00) Samara, Ulyanovsk, Saratov",
    "utc": ["Europe/Astrakhan", "Europe/Samara", "Europe/Ulyanovsk"]
  },
  {
    "value": "Iran Standard Time",
    "abbr": "IDT",
    "offset": 4.5,
    "isdst": true,
    "text": "(UTC+03:30) Tehran",
    "utc": ["Asia/Tehran"]
  },
  {
    "value": "Arabian/Azerbaijan Standard Time",
    "abbr": "AST/ADT",
    "offset": 4,
    "isdst": false,
    "text": "(UTC+04:00) Abu Dhabi, Muscat, Baku",
    "utc": ["Asia/Dubai", "Asia/Muscat", "Etc/GMT-4"]
  },
  {
    "value": "Georgian/Mauritius Standard Time",
    "abbr": "GET/MST",
    "offset": 4,
    "isdst": false,
    "text": "(UTC+04:00) Tbilisi, Port Louis",
    "utc": ["Asia/Tbilisi"]
  },
  {
    "value": "Afghanistan Standard Time",
    "abbr": "AST",
    "offset": 4.5,
    "isdst": false,
    "text": "(UTC+04:30) Kabul",
    "utc": ["Asia/Kabul"]
  },
  {
    "value": "West Asia Standard Time",
    "abbr": "WAST",
    "offset": 5,
    "isdst": false,
    "text": "(UTC+05:00) Ashgabat, Tashkent",
    "utc": [
      "Antarctica/Mawson",
      "Asia/Aqtau",
      "Asia/Aqtobe",
      "Asia/Ashgabat",
      "Asia/Dushanbe",
      "Asia/Oral",
      "Asia/Samarkand",
      "Asia/Tashkent",
      "Etc/GMT-5",
      "Indian/Kerguelen",
      "Indian/Maldives"
    ]
  },
  {
    "value": "Yekaterinburg Time",
    "abbr": "YEKT",
    "offset": 5,
    "isdst": false,
    "text": "(UTC+05:00) Yekaterinburg",
    "utc": ["Asia/Yekaterinburg"]
  },
  {
    "value": "Pakistan Standard Time",
    "abbr": "PKT",
    "offset": 5,
    "isdst": false,
    "text": "(UTC+05:00) Islamabad, Karachi",
    "utc": ["Asia/Karachi"]
  },
  {
    "value": "India Standard Time",
    "abbr": "IST",
    "offset": 5.5,
    "isdst": false,
    "text": "(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi",
    "utc": ["Asia/Kolkata"]
  },
  {
    "value": "Sri Lanka Standard Time",
    "abbr": "SLST",
    "offset": 5.5,
    "isdst": false,
    "text": "(UTC+05:30) Sri Jayawardenepura",
    "utc": ["Asia/Colombo"]
  },
  {
    "value": "Nepal Standard Time",
    "abbr": "NST",
    "offset": 5.75,
    "isdst": false,
    "text": "(UTC+05:45) Kathmandu",
    "utc": ["Asia/Kathmandu"]
  },
  {
    "value": "Central Asia Standard Time",
    "abbr": "CAST",
    "offset": 6,
    "isdst": false,
    "text": "(UTC+06:00) Nur-Sultan (Astana), Dhaka",
    "utc": ["Antarctica/Vostok", "Asia/Almaty", "Asia/Bishkek", "Asia/Qyzylorda", "Asia/Urumqi", "Etc/GMT-6", "Indian/Chagos"]
  },
  {
    "value": "Myanmar Standard Time",
    "abbr": "MST",
    "offset": 6.5,
    "isdst": false,
    "text": "(UTC+06:30) Yangon (Rangoon)",
    "utc": ["Asia/Rangoon", "Indian/Cocos"]
  },
  {
    "value": "N. Central/SE Asia Standard Time",
    "abbr": "NCAST/SAST",
    "offset": 7,
    "isdst": false,
    "text": "(UTC+07:00) Novosibirsk",
    "utc": ["Asia/Novokuznetsk", "Asia/Novosibirsk", "Asia/Omsk"]
  },
  {
    "value": "North Asia Standard Time",
    "abbr": "NAST",
    "offset": 8,
    "isdst": false,
    "text": "(UTC+08:00) Krasnoyarsk",
    "utc": ["Asia/Krasnoyarsk"]
  },
  {
    "value": "Singapore/W. Australia Standard Time",
    "abbr": "MPST/WAST",
    "offset": 8,
    "isdst": false,
    "text": "(UTC+08:00) Kuala Lumpur, Singapore",
    "utc": ["Asia/Brunei", "Asia/Kuala_Lumpur", "Asia/Kuching", "Asia/Makassar", "Asia/Manila", "Asia/Singapore", "Etc/GMT-8"]
  },
  {
    "value": "Taipei Standard Time",
    "abbr": "TST",
    "offset": 8,
    "isdst": false,
    "text": "(UTC+08:00) Taipei",
    "utc": ["Asia/Taipei"]
  },
  {
    "value": "Ulaanbaatar Standard Time",
    "abbr": "UST",
    "offset": 8,
    "isdst": false,
    "text": "(UTC+08:00) Ulaanbaatar",
    "utc": ["Asia/Choibalsan", "Asia/Ulaanbaatar"]
  },
  {
    "value": "North Asia East Standard Time",
    "abbr": "NAEST",
    "offset": 8,
    "isdst": false,
    "text": "(UTC+08:00) Irkutsk",
    "utc": ["Asia/Irkutsk"]
  },
  {
    "value": "Japan Standard Time",
    "abbr": "JST",
    "offset": 9,
    "isdst": false,
    "text": "(UTC+09:00) Osaka, Sapporo, Tokyo",
    "utc": ["Asia/Dili", "Asia/Jayapura", "Asia/Tokyo", "Etc/GMT-9", "Pacific/Palau"]
  },
  {
    "value": "Korea Standard Time",
    "abbr": "KST",
    "offset": 9,
    "isdst": false,
    "text": "(UTC+09:00) Seoul",
    "utc": ["Asia/Pyongyang", "Asia/Seoul"]
  },
  {
    "value": "AUS Central Standard Time",
    "abbr": "ACST",
    "offset": 9.5,
    "isdst": false,
    "text": "(UTC+09:30) Darwin",
    "utc": ["Australia/Darwin"]
  },
  {
    "value": "E. Australia Standard Time",
    "abbr": "EAST",
    "offset": 10,
    "isdst": false,
    "text": "(UTC+10:00) Brisbane",
    "utc": ["Australia/Brisbane", "Australia/Lindeman"]
  },
  {
    "value": "AUS Eastern Standard Time",
    "abbr": "AEST",
    "offset": 10,
    "isdst": false,
    "text": "(UTC+10:00) Canberra, Melbourne, Sydney",
    "utc": ["Australia/Melbourne", "Australia/Sydney"]
  },
  {
    "value": "West Pacific Standard Time",
    "abbr": "WPST",
    "offset": 10,
    "isdst": false,
    "text": "(UTC+10:00) Guam, Port Moresby",
    "utc": ["Antarctica/DumontDUrville", "Etc/GMT-10", "Pacific/Guam", "Pacific/Port_Moresby", "Pacific/Saipan", "Pacific/Truk"]
  },
  {
    "value": "Tasmania Standard Time",
    "abbr": "TST",
    "offset": 10,
    "isdst": false,
    "text": "(UTC+10:00) Hobart",
    "utc": ["Australia/Currie", "Australia/Hobart"]
  },
  {
    "value": "Yakutsk Standard Time",
    "abbr": "YST",
    "offset": 9,
    "isdst": false,
    "text": "(UTC+09:00) Yakutsk",
    "utc": ["Asia/Chita", "Asia/Khandyga", "Asia/Yakutsk"]
  },
  {
    "value": "Central Pacific/Vladivostok Standard Time",
    "abbr": "CPST/VST",
    "offset": 11,
    "isdst": false,
    "text": "(UTC+11:00) Solomon Is., New Caledonia",
    "utc": ["Antarctica/Macquarie", "Etc/GMT-11", "Pacific/Efate", "Pacific/Guadalcanal", "Pacific/Kosrae", "Pacific/Noumea", "Pacific/Ponape"]
  },
  {
    "value": "New Zealand Standard Time",
    "abbr": "NZST",
    "offset": 12,
    "isdst": false,
    "text": "(UTC+12:00) Auckland, Wellington",
    "utc": ["Antarctica/McMurdo", "Pacific/Auckland"]
  },
  {
    "value": "Fiji/Magadan Standard Time",
    "abbr": "FST/MST",
    "offset": 12,
    "isdst": false,
    "text": "(UTC+12:00) Fiji, Magadan",
    "utc": ["Pacific/Fiji"]
  },
  {
    "value": "Kamchatka Standard Time",
    "abbr": "KDT",
    "offset": 13,
    "isdst": true,
    "text": "(UTC+12:00) Petropavlovsk-Kamchatsky - Old",
    "utc": ["Asia/Kamchatka"]
  },
  {
    "value": "Samoa/Tonga Standard Time",
    "abbr": "SST/TST",
    "offset": 13,
    "isdst": false,
    "text": "(UTC+13:00) Samoa",
    "utc": ["Pacific/Apia"]
  }
];
