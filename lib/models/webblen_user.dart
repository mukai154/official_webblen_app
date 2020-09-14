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
  bool isCommunityBuilder;
  bool isNewCommunityBuilder;
  bool notifyFlashEvents;
  bool notifyFriendRequests;
  bool notifyHotEvents;
  bool notifySuggestedEvents;
  bool notifyWalletDeposits;
  bool notifyNewMessages;
  int lastNotifInMilliseconds;
  int messageNotificationCount;
  int friendRequestNotificationCount;
  int achievementNotificationCount;
  int eventNotificationCount;
  int walletNotificationCount;
  int communityBuilderNotificationCount;
  int notificationCount;
  bool isOnWaitList;
  String messageToken;
  bool isNew;
  bool canMakeAds;
  int apLvl;
  double ap;
  int lastPayoutTimeInMilliseconds;
  int eventsToLvlUp;
  List following;
  List followers;

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
    this.notifyFlashEvents,
    this.notifyFriendRequests,
    this.notifyHotEvents,
    this.notifySuggestedEvents,
    this.notifyWalletDeposits,
    this.notifyNewMessages,
    this.lastNotifInMilliseconds,
    this.messageNotificationCount,
    this.friendRequestNotificationCount,
    this.achievementNotificationCount,
    this.eventNotificationCount,
    this.walletNotificationCount,
    this.isCommunityBuilder,
    this.communityBuilderNotificationCount,
    this.notificationCount,
    this.isNewCommunityBuilder,
    this.isOnWaitList,
    this.messageToken,
    this.isNew,
    this.canMakeAds,
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
          notifyHotEvents: data['notifyHotEvents'],
          notifyFlashEvents: data['notifyFlashEvents'],
          notifyFriendRequests: data['notifyFriendRequests'],
          notifySuggestedEvents: data['notifySuggestedEvents'],
          notifyWalletDeposits: data['notifyWalletDeposits'],
          notifyNewMessages: data['notifyNewMessages'],
          lastNotifInMilliseconds: data['lastNotifInMilliseconds'],
          messageNotificationCount: data['messageNotificationCount'],
          friendRequestNotificationCount: data['friendRequestNotificationCount'],
          achievementNotificationCount: data['achievementNotificationCount'],
          eventNotificationCount: data['eventNotificationCount'],
          walletNotificationCount: data['walletNotificationCount'],
          isCommunityBuilder: data['isCommunityBuilder'],
          isNewCommunityBuilder: data['isNewCommunityBuilder'],
          communityBuilderNotificationCount: data['communityBuilderNotificationCount'],
          notificationCount: data['notificationCount'],
          isOnWaitList: data['isOnWaitList'],
          messageToken: data['messageToken'],
          isNew: data['isNew'],
          canMakeAds: data['canMakeAds'],
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
        'notifyFlashEvents': this.notifyFlashEvents,
        'notifyHotEvents': this.notifyHotEvents,
        'notifyFriendRequests': this.notifyFriendRequests,
        'notifySuggestedEvents': this.notifySuggestedEvents,
        'notifyWalletDeposits': this.notifyWalletDeposits,
        'notifyNewMessages': this.notifyNewMessages,
        'lastNotifInMilliseconds': this.lastNotifInMilliseconds,
        'messageNotificationCount': this.messageNotificationCount,
        'friendRequestNotificationCount': this.friendRequestNotificationCount,
        'achievementNotificationCount': this.achievementNotificationCount,
        'eventNotificationCount': this.eventNotificationCount,
        'walletNotificationCount': this.walletNotificationCount,
        'isCommunityBuilder': this.isCommunityBuilder,
        'communityBuilderNotificationCount': this.communityBuilderNotificationCount,
        'isNewCommunityBuilder': this.isNewCommunityBuilder,
        'notificationCount': this.notificationCount,
        'isOnWaitList': this.isOnWaitList,
        'messageToken': this.messageToken,
        'isNew': this.isNew,
        'canMakeAds': this.canMakeAds,
        'ap': this.ap,
        'apLvl': this.apLvl,
        'lastPayoutTimeInMilliseconds': this.lastPayoutTimeInMilliseconds,
        'eventsToLvlUp': this.eventsToLvlUp,
        'following': this.following,
        'followers': this.followers,
      };
}
