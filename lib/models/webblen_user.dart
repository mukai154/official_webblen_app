class WebblenUser {

  List blockedUsers;
  String username;
  String uid;
  String profile_pic;
  double eventPoints;
  double impactPoints;
  double userLat;
  double userLon;
  String lastCheckIn;
  List eventHistory;
  List rewards;
  List savedEvents;
  List friends;
  List friendRequests;
  List achievements;
  bool isCommunityBuilder;
  bool isNewCommunityBuilder;
  bool notifyFlashEvents;
  bool notifyFriendRequests;
  bool notifyHotEvents;
  bool notifySuggestedEvents;
  bool notifyWalletDeposits;
  bool notifyNewMessages;
  String lastNotificationSentAt;
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
  Map<dynamic, dynamic> location;
  Map<dynamic, dynamic> communities;
  Map<dynamic, dynamic> followingCommunities;
  bool canMakeAds;




  WebblenUser({
    this.blockedUsers,
    this.username,
    this.uid,
    this.profile_pic,
    this.eventPoints,
    this.impactPoints,
    this.userLat,
    this.userLon,
    this.lastCheckIn,
    this.eventHistory,
    this.rewards,
    this.savedEvents,
    this.friends,
    this.friendRequests,
    this.achievements,
    this.notifyFlashEvents,
    this.notifyFriendRequests,
    this.notifyHotEvents,
    this.notifySuggestedEvents,
    this.notifyWalletDeposits,
    this.notifyNewMessages,
    this.lastNotificationSentAt,
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
    this.location,
    this.communities,
    this.followingCommunities,
    this.canMakeAds,
  });

  WebblenUser.fromMap(Map<String, dynamic> data)
      : this(
      blockedUsers: data['blockedUsers'],
      username: data['username'],
      uid: data['uid'],
      profile_pic: data['profile_pic'],
      eventPoints: data['eventPoints'] * 1.00,
      impactPoints: data['impactPoints'] * 1.00,
      userLat: data['userLat'],
      userLon: data['userLon'],
      lastCheckIn: data['lastCheckIn'],
      eventHistory: data['eventHistory'],
      rewards: data['rewards'],
      savedEvents: data['savedEvents'],
      friends: data['friends'],
      friendRequests: data['friendRequests'],
      achievements: data['acheivements'],
      notifyHotEvents: data['notifyHotEvents'],
      notifyFlashEvents: data['notifyFlashEvents'],
      notifyFriendRequests: data['notifyFriendRequests'],
      notifySuggestedEvents: data['notifySuggestedEvents'],
      notifyWalletDeposits: data['notifyWalletDeposits'],
      notifyNewMessages: data['notifyNewMessages'],
      lastNotificationSentAt: data['lastNotificationSentAt'],
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
      location: data['location'],
      communities: data['communities'],
      followingCommunities: data['followingCommunities'],
      canMakeAds: data['canMakeAds']
  );

  Map<String, dynamic> toMap() => {
    'blockedUsers': this.blockedUsers,
    'username': this.username,
    'uid': this.uid,
    'profile_pic': this.profile_pic,
    'eventPoints': this.eventPoints,
    'impactPoints': this.impactPoints,
    'userLat': this.userLat,
    'userLon': this.userLon,
    'lastCheckIn': this.lastCheckIn,
    'eventHistory': this.eventHistory,
    'rewards': this.rewards,
    'savedEvents': this.savedEvents,
    'friends': this.friends,
    'friendRequests': this.friendRequests,
    'achievements': this.achievements,
    'notifyFlashEvents': this.notifyFlashEvents,
    'notifyHotEvents': this.notifyHotEvents,
    'notifyFriendRequests': this.notifyFriendRequests,
    'notifySuggestedEvents': this.notifySuggestedEvents,
    'notifyWalletDeposits': this.notifyWalletDeposits,
    'notifyNewMessages': this.notifyNewMessages,
    'lastNotificationSentAt': this.lastNotificationSentAt,
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
    'location': this.location,
    'communities': this.communities,
    'followingCommunities': this.followingCommunities,
    'canMakeAds': this.canMakeAds
  };
}