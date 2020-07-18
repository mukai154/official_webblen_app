class Timezones {
  static final timezones = [
    {
      "value": "Dateline Standard Time",
      "abbr": "DST",
      "offset": -12,
      "isdst": false,
      "text": "(UTC-12:00) International Date Line West",
      "utc": ["Etc/GMT+12"]
    },
    {
      "value": "Hawaiian Standard Time",
      "abbr": "HST",
      "offset": -10,
      "isdst": false,
      "text": "(UTC-10:00) Hawaii",
      "utc": ["Etc/GMT+10", "Pacific/Honolulu", "Pacific/Johnston", "Pacific/Rarotonga", "Pacific/Tahiti"]
    },
    {
      "value": "Alaskan Standard Time",
      "abbr": "AKDT",
      "offset": -8,
      "isdst": true,
      "text": "(UTC-09:00) Alaska",
      "utc": ["America/Anchorage", "America/Juneau", "America/Nome", "America/Sitka", "America/Yakutat"]
    },
    {
      "value": "Pacific Daylight Time",
      "abbr": "PDT",
      "offset": -7,
      "isdst": true,
      "text": "(UTC-07:00) Pacific Time (US & Canada & Mexico)",
      "utc": ["America/Dawson", "America/Los_Angeles", "America/Tijuana", "America/Vancouver", "America/Whitehorse"]
    },
    {
      "value": "Pacific Standard Time",
      "abbr": "PST",
      "offset": -8,
      "isdst": false,
      "text": "(UTC-08:00) Pacific Time (US & Canada)",
      "utc": ["America/Dawson", "America/Los_Angeles", "America/Tijuana", "America/Vancouver", "America/Whitehorse", "PST8PDT"]
    },
    {
      "value": "US Mountain Standard Time",
      "abbr": "UMST",
      "offset": -7,
      "isdst": false,
      "text": "(UTC-07:00) Arizona",
      "utc": ["America/Creston", "America/Dawson_Creek", "America/Hermosillo", "America/Phoenix", "Etc/GMT+7"]
    },
    {
      "value": "Mountain/Central America Standard Time",
      "abbr": "MDT/CAST",
      "offset": -6,
      "isdst": true,
      "text": "(UTC-07:00) Mountain Time (US & Canada & Mexico), Central America",
      "utc": [
        "America/Boise",
        "America/Cambridge_Bay",
        "America/Denver",
        "America/Edmonton",
        "America/Inuvik",
        "America/Ojinaga",
        "America/Yellowknife",
        "MST7MDT"
      ]
    },
    {
      "value": "Central Standard Time",
      "abbr": "CDT",
      "offset": -5,
      "isdst": true,
      "text": "(UTC-06:00) Central Time (US & Canada & Mexico)",
      "utc": [
        "America/Chicago",
        "America/Indiana/Knox",
        "America/Indiana/Tell_City",
        "America/Matamoros",
        "America/Menominee",
        "America/North_Dakota/Beulah",
        "America/North_Dakota/Center",
        "America/North_Dakota/New_Salem",
        "America/Rainy_River",
        "America/Rankin_Inlet",
        "America/Resolute",
        "America/Winnipeg",
        "CST6CDT"
      ]
    },
    {
      "value": "Canada Central Standard Time",
      "abbr": "CCST",
      "offset": -6,
      "isdst": false,
      "text": "(UTC-06:00) Saskatchewan",
      "utc": ["America/Regina", "America/Swift_Current"]
    },
    {
      "value": "SA Pacific Standard Time",
      "abbr": "SPST",
      "offset": -5,
      "isdst": false,
      "text": "(UTC-05:00) Bogota, Lima, Quito",
      "utc": [
        "America/Bogota",
        "America/Cayman",
        "America/Coral_Harbour",
        "America/Eirunepe",
        "America/Guayaquil",
        "America/Jamaica",
        "America/Lima",
        "America/Panama",
        "America/Rio_Branco",
        "Etc/GMT+5"
      ]
    },
    {
      "value": "Eastern Standard Time",
      "abbr": "EDT",
      "offset": -4,
      "isdst": true,
      "text": "(UTC-05:00) Eastern Time (US & Canada)",
      "utc": [
        "America/Detroit",
        "America/Havana",
        "America/Indiana/Petersburg",
        "America/Indiana/Vincennes",
        "America/Indiana/Winamac",
        "America/Iqaluit",
        "America/Kentucky/Monticello",
        "America/Louisville",
        "America/Montreal",
        "America/Nassau",
        "America/New_York",
        "America/Nipigon",
        "America/Pangnirtung",
        "America/Port-au-Prince",
        "America/Thunder_Bay",
        "America/Toronto",
        "EST5EDT"
      ]
    },
    {
      "value": "US Eastern Standard Time",
      "abbr": "UEDT",
      "offset": -4,
      "isdst": true,
      "text": "(UTC-05:00) Indiana (East)",
      "utc": ["America/Indiana/Marengo", "America/Indiana/Vevay", "America/Indianapolis"]
    },
    {
      "value": "Venezuela Standard Time",
      "abbr": "VST",
      "offset": -4.5,
      "isdst": false,
      "text": "(UTC-04:30) Caracas",
      "utc": ["America/Caracas"]
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
      "value": "Pacific SA Standard Time",
      "abbr": "PSST",
      "offset": -4,
      "isdst": false,
      "text": "(UTC-04:00) Santiago",
      "utc": ["America/Santiago", "Antarctica/Palmer"]
    },
    {
      "value": "Newfoundland Standard Time",
      "abbr": "NDT",
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
      "abbr": "GDT/MST",
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
      "abbr": "CVST/ADT",
      "offset": -1,
      "isdst": false,
      "text": "(UTC-01:00) Cape Verde Is., Azores",
      "utc": ["Atlantic/Cape_Verde", "Etc/GMT+1"]
    },
    {
      "value": "Morocco Standard Time",
      "abbr": "MDT",
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
      "abbr": "WEDT",
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
      "abbr": "RDT",
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
      "abbr": "MEDT",
      "offset": 3,
      "isdst": true,
      "text": "(UTC+02:00) Beirut",
      "utc": ["Asia/Beirut"]
    },
    {
      "value": "Egypt Standard Time",
      "abbr": "EST",
      "offset": 2,
      "isdst": false,
      "text": "(UTC+02:00) Cairo",
      "utc": ["Africa/Cairo"]
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
      "value": "China Standard Time",
      "abbr": "CST",
      "offset": 8,
      "isdst": false,
      "text": "(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi",
      "utc": ["Asia/Hong_Kong", "Asia/Macau", "Asia/Shanghai"]
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
}
