class WebblenUser {
  // ignore: non_constant_identifier_names
  double WBLN;
  List achievements;
  double ap;
  int apLvl;
  List blockedUsers;
  String emailAddress;
  int eventsToLvlUp;
  String fbAccessToken;
  List followers;
  List following;
  String googleAccessToken;
  String googleIDToken;
  String id;
  bool isAdmin;
  String profilePicURL;
  String username;
  String bio;
  String website;

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
      };
}
