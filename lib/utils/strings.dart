import 'dart:io';

class Strings {
  static final String googleAPIKEY = "AIzaSyApD1l8k7XAUQ7jOMA0p9edI6JllSbCawM";
  static final String twitterCONSUMERKEY = "qE3eqc6zEr1iFamNEkyyJzztT";
  static final String twitterCONSUMERSECRET = "8nKtKawnraVuhYJVE0yAha153qeG01KgkiA0uw6HjbXIzIk5wm";
  static final String ethNetworkID = "c873a87ae50a4095ae3e3af99e42016f";
  static final String ethNetworkSecret = "1a2ba470d48d46cf9840cca6cbe38baa";
  static final String stripePublishableKey = "pk_test_gYHQOvqAIkPEMVGQRehk3nj4009Kfodta1";
  static final String stripeSecretKey = "sk_live_2g2I4X6pIDNbJGHy5XIXUjKr00IRUj3Ngx";
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
}
