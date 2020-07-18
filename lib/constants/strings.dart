import 'dart:io';

class Strings {
  static final String googleAPIKEY = "AIzaSyBJVHmY_WAjWfpz69S_4n-Bt6HRc-YO6WM";
  static final String proxyMapsURL = "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api";

  //Methods
  bool isEmailValid(String val) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val);
    return emailValid;
  }

  String getAdMobBannerID() {
    if (Platform.isIOS) {
      return 'ca-app-pub-2136415475966451/7219950981';
      //return 'ca-app-pub-3940256099942544/2934735716';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-2136415475966451/5844673029';
      //return 'ca-app-pub-3940256099942544/6300978111';
    }
    return null;
  }

  bool isUsernameValid(String val) {
    bool userNameIsValid = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(val);
    return userNameIsValid;
  }

  List<String> timeListFromSelectedTime(String selectedTime) {
    int index = timeList.indexOf(selectedTime);
    List<String> newList = selectedTime == "11:30 PM" ? ['11:30 PM', '11:59 PM'] : timeList.sublist(index, timeList.length);
    return newList;
  }

  //Values
  static final List<String> statesList = [
    'AL',
    'AK',
    'AS',
    'AZ',
    'AR',
    'CA',
    'CO',
    'CT',
    'DE',
    'DC',
    'FM',
    'FL',
    'GA',
    'GU',
    'HI',
    'ID',
    'IL',
    'IN',
    'IA',
    'KS',
    'KY',
    'LA',
    'ME',
    'MH',
    'MD',
    'MA',
    'MI',
    'MN',
    'MS',
    'MO',
    'MT',
    'NE',
    'NV',
    'NH',
    'NJ',
    'NM',
    'NY',
    'NC',
    'ND',
    'MP',
    'OH',
    'OK',
    'OR',
    'PW',
    'PA',
    'PR',
    'RI',
    'SC',
    'SD',
    'TN',
    'TX',
    'UT',
    'VT',
    'VI',
    'VA',
    'WA',
    'WV',
    'WI',
    'WY'
  ];

  static final List<String> timeList = [
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

  static final List<String> eventTypes = [
    'Select Event Type',
    'Appearance/Signing',
    'Attraction',
    'Camp, Trip, or Retreat',
    'Class, Training, or Workshop',
    'Concert/Performance',
    'Conference',
    'Convention',
    'Dinner/Gala',
    'E-Sports Tournament',
    'Festival/Fair',
    'Game/Competition',
    'Networking Event',
    'Party/Social Gathering',
    'Race/Endurance Event',
    'Rally',
    'Screening',
    'Seminar/Talk',
    'Tour',
    'Tournament',
    'Tradeshow/Expo',
    'Other',
  ];

  static final List<String> eventTypeFilters = [
    'None',
    'Appearance/Signing',
    'Attraction',
    'Camp, Trip, or Retreat',
    'Class, Training, or Workshop',
    'Concert/Performance',
    'Conference',
    'Convention',
    'Dinner/Gala',
    'E-Sports Tournament',
    'Festival/Fair',
    'Game/Competition',
    'Networking Event',
    'Party/Social Gathering',
    'Race/Endurance Event',
    'Rally',
    'Screening',
    'Seminar/Talk',
    'Tour',
    'Tournament',
    'Tradeshow/Expo',
    'Other',
  ];

  static final List<String> eventCategories = [
    'Select Event Category',
    'Auto, Boat, & Air',
    'Business/Professional',
    'Charity/Causes',
    'Family & Education',
    'Fashion & Beauty',
    'Film, Media, & Entertainment',
    'Food/Drink',
    'Government/Politics',
    'Health & Wellness',
    'Hobbies/Special Interests',
    'Home/Lifestyle',
    'Music',
    'Religion/Spirituality',
    'School Activities',
    'Science/Technology',
    'Seasonal/Holiday',
    'Sports/Fitness',
    'Theatre/Visual Arts',
    'Travel/Outdoor',
  ];

  static final List<String> eventCategoryFilters = [
    'None',
    'Auto, Boat, & Air',
    'Business/Professional',
    'Charity/Causes',
    'Family & Education',
    'Fashion & Beauty',
    'Film, Media, & Entertainment',
    'Food/Drink',
    'Government/Politics',
    'Health & Wellness',
    'Hobbies/Special Interests',
    'Home/Lifestyle',
    'Music',
    'Religion/Spirituality',
    'School Activities',
    'Science/Technology',
    'Seasonal/Holiday',
    'Sports/Fitness',
    'Theatre/Visual Arts',
    'Travel/Outdoor',
  ];
}
