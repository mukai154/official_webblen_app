import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/random_image_generator.dart';

class WebblenUser {
  // ignore: non_constant_identifier_names
  double? WBLN;
  List? achievements;
  double? ap;
  int? apLvl;
  List? blockedUsers;
  String? emailAddress;
  int? eventsToLvlUp;
  String? fbAccessToken;
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
  List? associatedTags;

  WebblenUser({
    // ignore: non_constant_identifier_names
    this.WBLN,
    this.achievements,
    this.ap,
    this.apLvl,
    this.blockedUsers,
    this.emailAddress,
    this.eventsToLvlUp,
    this.fbAccessToken,
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
    this.associatedTags,
  });

  WebblenUser.fromMap(Map<String, dynamic> data)
      : this(
          WBLN: data['WBLN'].toDouble(),
          achievements: data['achievements'],
          ap: data['ap'],
          apLvl: data['apLvl'],
          blockedUsers: data['blockedUsers'],
          emailAddress: data['emailAddress'],
          eventsToLvlUp: data['eventsToLvlUp'],
          fbAccessToken: data['fbAccessToken'],
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
          associatedTags: data['associatedTags'],
        );

  Map<String, dynamic> toMap() => {
        'WBLN': this.WBLN,
        'achievements': this.achievements,
        'ap': this.ap,
        'apLvl': this.apLvl,
        'blockedUsers': this.blockedUsers,
        'emailAddress': this.emailAddress,
        'eventsToLvlUp': this.eventsToLvlUp,
        'fbAccessToken': this.fbAccessToken,
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
        'associatedTags': this.associatedTags,
      };

  WebblenUser generateNewUser(String id) {
    String randomUsername = "user" + getRandomString(5);
    String randomImgURL = getRandomImageURL();
    WebblenUser user = WebblenUser(
      id: id,
      WBLN: 5.0001,
      achievements: [],
      ap: 1.00,
      apLvl: 1,
      blockedUsers: [],
      emailAddress: null,
      eventsToLvlUp: 20,
      fbAccessToken: null,
      followers: [],
      following: [],
      googleAccessToken: null,
      googleIDToken: googleIDToken,
      isAdmin: false,
      profilePicURL: randomImgURL,
      username: randomUsername,
      bio: null,
      website: null,
      isPrivate: false,
      recentSearchTerms: [],
      onboarded: false,
      lastSeenZipcode: "58104",
      lastSeenCity: "Fargo",
      associatedTags: [],
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
}
