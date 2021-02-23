class WebblenUser {
  // ignore: non_constant_identifier_names
  double WBLN;
  List<String> achievements;
  double ap;
  int apLvl;
  List<String> blockedUsers;
  String emailAddress;
  int eventsToLvlUp;
  String fbAccessToken;
  List<String> followers;
  List<String> following;
  String googleAccessToken;
  String googleIDToken;
  String id;
  bool isAdmin;
  String profilePicURL;
  String username;

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
  });

  WebblenUser.fromMap(Map<String, dynamic> data)
      : this(
          WBLN: data['WBLN'].toDouble(),
          achievements: data['achievements'].cast<String>(),
          ap: data['ap'],
          apLvl: data['apLvl'],
          blockedUsers: data['blockedUsers'].cast<String>(),
          emailAddress: data['emailAddress'],
          eventsToLvlUp: data['eventsToLvlUp'],
          fbAccessToken: data['fbAccessToken'],
          followers: data['followers'].cast<String>(),
          following: data['following'].cast<String>(),
          googleAccessToken: data['googleAccessToken'],
          googleIDToken: data['googleIDToken'],
          id: data['id'],
          isAdmin: data['isAdmin'],
          profilePicURL: data['profilePicURL'],
          username: data['username'],
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
      };
}
