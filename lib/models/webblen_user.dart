import 'package:webblen/utils/custom_string_methods.dart';

class WebblenUser {
  // ignore: non_constant_identifier_names
  double? WBLN;
  List? achievements;
  double? ap;
  int? apLvl;
  List? blockedUsers;
  String? emailAddress;
  int? eventsToLvlUp;
  bool? isCheckedIntoEvent;
  bool? isCheckedIntoStream;
  String? fbAccessToken;
  List? mutedBy;
  List? followers;
  List? following;
  String? googleAccessToken;
  String? googleIDToken;
  String? id;
  bool? isAdmin;
  String? profilePicURL;
  String? username;
  String? bio;
  String? website;
  bool? isPrivate;
  List? recentSearchTerms;
  bool? onboarded;
  String? lastSeenZipcode;
  String? lastSeenCity;
  List? tags;

  WebblenUser({
    // ignore: non_constant_identifier_names
    this.WBLN,
    this.achievements,
    this.ap,
    this.apLvl,
    this.blockedUsers,
    this.emailAddress,
    this.eventsToLvlUp,
    this.isCheckedIntoEvent,
    this.isCheckedIntoStream,
    this.fbAccessToken,
    this.mutedBy,
    this.followers,
    this.following,
    this.googleAccessToken,
    this.googleIDToken,
    this.id,
    this.isAdmin,
    this.profilePicURL,
    this.username,
    this.bio,
    this.website,
    this.isPrivate,
    this.recentSearchTerms,
    this.onboarded,
    this.lastSeenZipcode,
    this.lastSeenCity,
    this.tags,
  });

  WebblenUser.fromMap(Map<String, dynamic> data)
      : this(
          WBLN: data['WBLN'].toDouble(),
          achievements: data['achievements'],
          ap: data['ap'].toDouble(),
          apLvl: data['apLvl'],
          blockedUsers: data['blockedUsers'],
          emailAddress: data['emailAddress'],
          eventsToLvlUp: data['eventsToLvlUp'],
          isCheckedIntoEvent: data['isCheckedIntoEvent'],
          isCheckedIntoStream: data['isCheckedIntoStream'],
          fbAccessToken: data['fbAccessToken'],
          mutedBy: data['mutedBy'],
          followers: data['followers'],
          following: data['following'],
          googleAccessToken: data['googleAccessToken'],
          googleIDToken: data['googleIDToken'],
          id: data['id'],
          isAdmin: data['isAdmin'],
          profilePicURL: data['profilePicURL'],
          username: data['username'],
          bio: data['bio'],
          website: data['website'],
          isPrivate: data['isPrivate'],
          recentSearchTerms: data['recentSearchTerms'],
          onboarded: data['onboarded'],
          lastSeenZipcode: data['lastSeenZipcode'],
          lastSeenCity: data['lastSeenCity'],
          tags: data['tags'],
        );

  Map<String, dynamic> toMap() => {
        'WBLN': this.WBLN,
        'achievements': this.achievements,
        'ap': this.ap,
        'apLvl': this.apLvl,
        'blockedUsers': this.blockedUsers,
        'emailAddress': this.emailAddress,
        'eventsToLvlUp': this.eventsToLvlUp,
        'isCheckedIntoEvent': this.isCheckedIntoEvent,
        'isCheckedIntoStream': this.isCheckedIntoStream,
        'fbAccessToken': this.fbAccessToken,
        'mutedBy': mutedBy,
        'followers': this.followers,
        'following': this.following,
        'googleAccessToken': this.googleAccessToken,
        'googleIDToken': this.googleIDToken,
        'id': this.id,
        'isAdmin': this.isAdmin,
        'profilePicURL': this.profilePicURL,
        'username': this.username,
        'bio': this.bio,
        'website': this.website,
        'isPrivate': this.isPrivate,
        'recentSearchTerms': this.recentSearchTerms,
        'onboarded': this.onboarded,
        'lastSeenZipcode': this.lastSeenZipcode,
        'lastSeenCity': this.lastSeenCity,
        'tags': this.tags,
      };

  WebblenUser generateNewUser(String id) {
    String randomUsername = "user" + getRandomString(5);
    String placeHolderImgURL = "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2Fuser_placeholder"
        ".png?alt=media&token=029df45f-79af-42a4-93a1-b8a7111516f9";
    WebblenUser user = WebblenUser(
      id: id,
      WBLN: 5.0001,
      achievements: [],
      ap: 1.00,
      apLvl: 1,
      blockedUsers: [],
      emailAddress: null,
      eventsToLvlUp: 20,
      isCheckedIntoEvent: false,
      isCheckedIntoStream: false,
      fbAccessToken: null,
      mutedBy: [],
      followers: [],
      following: [],
      googleAccessToken: null,
      googleIDToken: googleIDToken,
      isAdmin: false,
      profilePicURL: placeHolderImgURL,
      username: randomUsername,
      bio: null,
      website: null,
      isPrivate: false,
      recentSearchTerms: [],
      onboarded: false,
      lastSeenZipcode: "58104",
      lastSeenCity: "Fargo",
      tags: [],
    );
    return user;
  }

  //checks if obj is valid
  bool isValid() {
    bool isValid = true;
    if (id == null) {
      isValid = false;
    }
    return isValid;
  }

  //checks if ob is identical to another
  bool isIdenticalTo(WebblenUser data) {
    bool isIdentical = false;
    if (this.toMap().toString() == data.toMap().toString()) {
      isIdentical = true;
    }
    return isIdentical;
  }
}
