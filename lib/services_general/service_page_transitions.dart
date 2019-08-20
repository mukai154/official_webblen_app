import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/user_pages/reward_payout_page.dart';
import 'package:webblen/user_pages/shop_page.dart';
import 'package:webblen/event_pages/event_check_in_page.dart';
import 'package:webblen/user_pages/user_ranks_page.dart';
import 'package:webblen/event_pages/create_reward_page.dart';
import 'package:webblen/user_pages/user_details_page.dart';
import 'package:webblen/event_pages/create_flash_event_page.dart';
import 'package:webblen/user_pages/friends_page.dart';
import 'package:webblen/user_pages/chat_page.dart';
import 'package:webblen/user_pages/messages_page.dart';
import 'package:webblen/community_pages/community_create_post_page.dart';
import 'package:webblen/user_pages/notifications_page.dart';
import 'package:webblen/user_pages/users_search_page.dart';
import 'package:webblen/user_pages/join_waitlist_page.dart';
import 'package:webblen/user_pages/settings_page.dart';
import 'package:webblen/user_pages/transaction_history_page.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/event_pages/event_details_page.dart';
import 'package:webblen/event_pages/create_event_page.dart';
import 'package:webblen/event_pages/event_attendees_page.dart';
import 'package:webblen/event_pages/event_edit_page.dart';
import 'package:webblen/user_pages/create_ad_page.dart';
import 'package:webblen/event_pages/create_recurring_event_page.dart';
import 'package:webblen/home_pages/wallet_page.dart';
import 'package:webblen/user_pages/discover_page.dart';
import 'package:webblen/community_pages/community_profile_page.dart';
import 'package:webblen/community_pages/choose_post_type_page.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/community_pages/my_communities_page.dart';
import 'package:webblen/community_pages/community_new_page.dart';
import 'package:webblen/community_pages/community_post_comments_page.dart';
import 'package:webblen/community_pages/invite_members_page.dart';
import 'package:webblen/user_pages/search_page.dart';
import 'package:webblen/community_pages/choose_community.dart';
import 'package:webblen/home_page.dart';
import 'package:webblen/auth_pages/choose_sim_page.dart';
import 'package:webblen/event_pages/webblen_events_page.dart';


class PageTransitionService{

  final BuildContext context;
  final bool isRecurring;
  final List userIDs;
  final String uid;
  final List<WebblenUser> usersList;
  final String username;
  final String areaName;

  final WebblenUser webblenUser;
  final WebblenUser currentUser;
  final WebblenChat chat;
  final String chatDocKey;
  final String peerUsername;
  final String peerProfilePic;
  final String profilePicUrl;
  final CommunityNewsPost newsPost;
  final WebblenReward reward;
  final Event event;
  final List<Event> events;
  final RecurringEvent recurringEvent;
  final String eventKey;
  final bool eventIsLive;
  final Community community;
  final String newEventOrPost;
  final bool viewingMembersOrAttendees;
  final String simLocation;
  final double simLat;
  final double simLon;

  PageTransitionService({
    this.context, this.username, this.isRecurring,
    this.uid, this.usersList, this.webblenUser,
    this.currentUser, this.chat, this.chatDocKey,
    this.peerProfilePic, this.peerUsername, this.profilePicUrl,
    this.newsPost, this.reward, this.event, this.recurringEvent,
    this.eventKey, this.userIDs, this.eventIsLive, this.community,
    this.areaName, this.newEventOrPost, this.viewingMembersOrAttendees,
    this.simLocation, this.simLat, this.simLon, this.events
  });

  void transitionToRootPage () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  void transitionToLoginPage () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  void transitionToChooseSim () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseSimPage()));
  void transitionToSim () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(simLocation: simLocation, simLat: simLat, simLon: simLon)));

  void returnToRootPage () => Navigator.of(context).popUntil((route) => route.isFirst);
//  void transitionToEventListPage () =>  Navigator.push(context, SlideFromRightRoute(widget: EventCalendarPage(currentUser: currentUser)));
//  void transitionToEventEditPage () =>  Navigator.push(context, SlideFromRightRoute(widget: EventEditPage(event: event, currentUser: currentUser, eventIsLive: eventIsLive)));
  void transitionToWebblenEventsPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => WebblenEventsFeedPage(currentUser: currentUser, events: events)));
  void transitionToNewEventPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEventPage(currentUser: currentUser, community: community, isRecurring: isRecurring)));
  void transitionToNewRecurringEventPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecurringEventPage(currentUser: currentUser, community: community)));
  void transitionToNewFlashEventPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateFlashEventPage(currentUser: currentUser)));
  void transitionToEventPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailsPage(event: event, currentUser: currentUser, eventIsLive: eventIsLive)));
  void transitionToReccurringEventPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => RecurringEventDetailsPage(event: recurringEvent, currentUser: currentUser)));
  void transitionToShopPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ShopPage(currentUser: currentUser)));
  void transitionToCheckInPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  EventCheckInPage(currentUser: currentUser)));
  void transitionToEventAttendeesPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  EventAttendeesPage(currentUser: currentUser, eventKey: eventKey,)));
  void transitionToUserRanksPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserRanksPage(simLocation: simLocation, simLat: simLat, simLon: simLon)));
  void transitionToCreateRewardPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CreateRewardPage()));
  void transitionToFriendsPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  FriendsPage(uid: uid)));
  void transitionToChatPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  Chat(chatDocKey: chatDocKey, currentUser: currentUser, peerProfilePic: peerProfilePic, peerUsername: peerUsername)));
  void transitionToMessagesPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  MessagesPage(currentUser: currentUser)));
  void transitionToCurrentUserDetailsPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CurrentUserDetailsPage(currentUser: currentUser)));
  void transitionToUserDetailsPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserDetailsPage(currentUser: currentUser, webblenUser: webblenUser)));
  void transitionToWalletPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  WalletPage(currentUser: currentUser)));
  void transitionToDiscoverPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  DiscoverPage(uid: uid, areaName: areaName, simLocation: simLocation, simLat: simLat, simLon: simLon)));
  void transitionToMyCommunitiesPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyCommunitiesPage(uid: uid, areaName: areaName)));
  void transitionToNewCommunityPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CreateCommunityPage(areaName: areaName)));
  void transitionToChoosePostTypePage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ChoosePostTypePage(currentUser: currentUser, community: community)));
  void transitionToPostCommentsPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CommunityPostCommentsPage(currentUser: currentUser, newsPost: newsPost)));
  void transitionToCommunityProfilePage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CommunityProfilePage(currentUser: currentUser, community: community)));
  void transitionToCommunityInvitePage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  InviteMembersPage(currentUser: currentUser, community: community)));
  void transitionToCommunityCreatePostPage () =>  Navigator.push(context, MaterialPageRoute(builder: (context) =>  CommunityCreatePostPage(currentUser: currentUser, community: community)));
//  void transitionToCommunityBuilderPage () => Navigator.push(context, SlideFromRightRoute(widget: CommunityCreatePostPage(currentUser: currentUser, community: community)));
  void transitionToNotificationsPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  NotificationPage(currentUser: currentUser)));
  void transitionToSearchPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  SearchPage(currentUser: currentUser, areaName: areaName)));
  void transitionToUserSearchPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserSearchPage(currentUser: currentUser, userIDs: userIDs, viewingMembersOrAttendees: viewingMembersOrAttendees)));
  void transitionToSettingsPage () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(currentUser: currentUser)));
  void transitionToRewardPayoutPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  RewardPayoutPage(redeemingReward: reward,currentUser: currentUser)));
  void transitionToTransactionHistoryPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  TransactionHistoryPage(currentUser: currentUser)));
  void transitionToWaitListPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  JoinWaitlistPage(currentUser: currentUser)));
  void transitionToChooseCommunityPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ChooseCommunityPage(uid: uid, newEventOrPost: newEventOrPost)));
  void transitionToCreateAdPage () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  CreateAdPage(currentUser: currentUser)));
}