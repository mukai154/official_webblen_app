class WebblenUser {
  List blockedUsers;
  String username;
  String uid;
  String profile_pic;
  double webblen;
  double eventPoints;
  double impactPoints;
  int lastCheckInTimeInMilliseconds;
  List eventHistory;
  List rewards;
  List savedEvents;
  List achievements;
  int lastNotifInMilliseconds;
  int messageNotificationCount;
  int notificationCount;
  int apLvl;
  double ap;
  int lastPayoutTimeInMilliseconds;
  int eventsToLvlUp;
  List following;
  List followers;
  List tags;

  // bool isCommunityBuilder;
  // bool isNewCommunityBuilder;
  // bool notifyFlashEvents;
  // bool notifyFriendRequests;
  // bool notifyHotEvents;
  // bool notifySuggestedEvents;
  // bool notifyWalletDeposits;
  // bool notifyNewMessages;

  WebblenUser({
    this.blockedUsers,
    this.username,
    this.uid,
    this.profile_pic,
    this.webblen,
    this.eventPoints,
    this.impactPoints,
    this.lastCheckInTimeInMilliseconds,
    this.eventHistory,
    this.rewards,
    this.savedEvents,
    this.achievements,
    this.lastNotifInMilliseconds,
    this.messageNotificationCount,
    this.notificationCount,
    this.apLvl,
    this.ap,
    this.lastPayoutTimeInMilliseconds,
    this.eventsToLvlUp,
    this.following,
    this.followers,
  });

  WebblenUser.fromMap(Map<String, dynamic> data)
      : this(
          blockedUsers: data['blockedUsers'],
          username: data['username'],
          uid: data['uid'],
          profile_pic: data['profile_pic'],
          webblen: data['webblen'] == null ? null : data['webblen'] * 1.00,
          eventPoints: data['eventPoints'] * 1.00,
          impactPoints: data['impactPoints'] * 1.00,
//      userLat: data['userLat'],
//      userLon: data['userLon'],
          lastCheckInTimeInMilliseconds: data['lastCheckInTimeInMilliseconds'],
          eventHistory: data['eventHistory'],
          rewards: data['rewards'],
          savedEvents: data['savedEvents'],
          achievements: data['acheivements'],
          lastNotifInMilliseconds: data['lastNotifInMilliseconds'],
          messageNotificationCount: data['messageNotificationCount'],
          notificationCount: data['notificationCount'],
          ap: data['ap'],
          apLvl: data['apLvl'],
          lastPayoutTimeInMilliseconds: data['lastPayoutTimeInMilliseconds'],
          eventsToLvlUp: data['eventsToLvlUp'],
          following: data['following'],
          followers: data['followers'],
        );

  Map<String, dynamic> toMap() => {
        'blockedUsers': this.blockedUsers,
        'username': this.username,
        'uid': this.uid,
        'profile_pic': this.profile_pic,
        'webblen': this.webblen,
        'eventPoints': this.eventPoints,
        'impactPoints': this.impactPoints,
        'lastCheckInTimeInMilliseconds': this.lastCheckInTimeInMilliseconds,
        'eventHistory': this.eventHistory,
        'rewards': this.rewards,
        'savedEvents': this.savedEvents,
        'achievements': this.achievements,
        'lastNotifInMilliseconds': this.lastNotifInMilliseconds,
        'messageNotificationCount': this.messageNotificationCount,
        'notificationCount': this.notificationCount,
        'ap': this.ap,
        'apLvl': this.apLvl,
        'lastPayoutTimeInMilliseconds': this.lastPayoutTimeInMilliseconds,
        'eventsToLvlUp': this.eventsToLvlUp,
        'following': this.following,
        'followers': this.followers,
      };
}
