import 'package:flutter/material.dart';

import 'package:webblen/pages/auth_pages/choose_sim_page.dart';
import 'package:webblen/pages/calendar_pages/my_calendar_page.dart';
import 'package:webblen/pages/calendar_pages/reminder_page.dart';
import 'package:webblen/pages/chat_pages/chat_invite_share_page.dart';
import 'package:webblen/pages/chat_pages/chat_page.dart';
import 'package:webblen/pages/chat_pages/chats_index_page.dart';
import 'package:webblen/pages/community_pages/choose_post_type_page.dart';
import 'package:webblen/pages/community_pages/communities_in_area_page.dart';
import 'package:webblen/pages/community_pages/community_create_post_page.dart';
import 'package:webblen/pages/community_pages/community_new_page.dart';
import 'package:webblen/pages/community_pages/community_post_comments_page.dart';
import 'package:webblen/pages/community_pages/community_profile_page.dart';
import 'package:webblen/pages/community_pages/invite_members_page.dart';
import 'package:webblen/pages/community_pages/my_communities_page.dart';
import 'package:webblen/pages/community_request_pages/community_request_details_page.dart';
import 'package:webblen/pages/community_request_pages/community_requests_page.dart';
import 'package:webblen/pages/community_request_pages/create_community_request.dart';
import 'package:webblen/pages/event_pages/create_edit_event_page.dart';
import 'package:webblen/pages/event_pages/create_flash_event_page.dart';
import 'package:webblen/pages/event_pages/create_recurring_event_page.dart';
import 'package:webblen/pages/event_pages/create_reward_page.dart';
import 'package:webblen/pages/event_pages/event_attendees_page.dart';
import 'package:webblen/pages/event_pages/event_check_in_page.dart';
import 'package:webblen/pages/event_pages/event_details_page.dart';
import 'package:webblen/pages/event_pages/webblen_events_page.dart';
import 'package:webblen/home_page.dart';
import 'package:webblen/pages/home_pages/wallet_page.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/community_request.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/pages/user_pages/add_com_image_page.dart';
import 'package:webblen/pages/user_pages/create_ad_page.dart';
import 'package:webblen/pages/user_pages/discover_page.dart';
import 'package:webblen/pages/user_pages/friends_page.dart';
import 'package:webblen/pages/user_pages/join_waitlist_page.dart';
import 'package:webblen/pages/user_pages/notifications_page.dart';
import 'package:webblen/pages/user_pages/reward_payout_page.dart';
import 'package:webblen/pages/user_pages/search_page.dart';
import 'package:webblen/pages/user_pages/settings_page.dart';
import 'package:webblen/pages/user_pages/shop_page.dart';
import 'package:webblen/pages/user_pages/transaction_history_page.dart';
import 'package:webblen/pages/user_pages/user_details_page.dart';
import 'package:webblen/pages/user_pages/user_ranks_page.dart';
import 'package:webblen/pages/user_pages/users_search_page.dart';
import 'package:webblen/utils/webblen_scanner.dart';

class PageTransitionService {
  final BuildContext context;
  final String action;
  final bool isRecurring;
  final List userIDs;
  final String uid;
  final List<WebblenUser> usersList;
  final String username;
  final String areaName;
  final CommunityRequest comRequest;
  final WebblenUser webblenUser;
  final WebblenUser currentUser;
  final WebblenChat chat;
  final String chatKey;
  final String peerUsername;
  final String peerProfilePic;
  final String profilePicUrl;
  final CommunityNewsPost newsPost;
  final WebblenReward reward;
  final Event event;
  final CalendarEvent calendarEvent;
  final List<Event> events;
  final RecurringEvent recurringEvent;
  final String eventKey;
  final bool eventIsLive;
  final Community community;
  final List<Community> communities;
  final String newEventOrPost;
  final bool viewingMembersOrAttendees;
  final String simLocation;
  final double simLat;
  final double simLon;

  PageTransitionService({
    this.context,
    this.action,
    this.username,
    this.isRecurring,
    this.uid,
    this.usersList,
    this.webblenUser,
    this.currentUser,
    this.chat,
    this.chatKey,
    this.peerProfilePic,
    this.peerUsername,
    this.profilePicUrl,
    this.newsPost,
    this.reward,
    this.event,
    this.recurringEvent,
    this.eventKey,
    this.userIDs,
    this.eventIsLive,
    this.community,
    this.areaName,
    this.newEventOrPost,
    this.viewingMembersOrAttendees,
    this.simLocation,
    this.simLat,
    this.simLon,
    this.events,
    this.comRequest,
    this.communities,
    this.calendarEvent,
  });

  //ROOT PAGES
  void transitionToRootPage() => Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (Route<dynamic> route) => false,
      );

  void transitionToLoginPage() => Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );

  void transitionToChooseSim() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChooseSimPage(),
        ),
      );

  void transitionToSim() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            simLocation: simLocation,
            simLat: simLat,
            simLon: simLon,
          ),
        ),
      );

  void returnToRootPage() => Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );

  //SEARCH
  void transitionToSearchPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(
            currentUser: currentUser,
            areaName: areaName,
          ),
        ),
      );

  void transitionToUserSearchPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserSearchPage(
            currentUser: currentUser,
            userIDs: userIDs,
            userList: usersList,
            viewingMembersOrAttendees: viewingMembersOrAttendees,
          ),
        ),
      );

  //EVENTS
  void transitionToWebblenEventsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebblenEventsFeedPage(
            currentUser: currentUser,
            events: events,
          ),
        ),
      );

  void transitionToCreateEditEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateEditEventPage(
            currentUser: currentUser,
            community: community,
            isRecurring: isRecurring,
            eventToEdit: event,
          ),
        ),
      );

  void transitionToNewRecurringEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRecurringEventPage(
            currentUser: currentUser,
            community: community,
          ),
        ),
      );

  void transitionToNewFlashEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateFlashEventPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(
            event: event,
            currentUser: currentUser,
            eventIsLive: eventIsLive,
          ),
        ),
      );

  void transitionToReccurringEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecurringEventDetailsPage(
            event: recurringEvent,
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToCheckInPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventCheckInPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToEventAttendeesPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventAttendeesPage(
            currentUser: currentUser,
            eventKey: eventKey,
          ),
        ),
      );

  //CALENDAR
  void transitionToCalendarPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCalendarPage(
            currentUser: currentUser,
          ),
        ),
      );
  void transitionToReminderPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReminderPage(
            event: calendarEvent,
            currentUser: currentUser,
          ),
        ),
      );

  //WEBBLEN ECON
  void transitionToWalletPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToShopPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShopPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToRewardPayoutPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RewardPayoutPage(
            redeemingReward: reward,
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToTransactionHistoryPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionHistoryPage(
            currentUser: currentUser,
          ),
        ),
      );

  //USERS
  void transitionToUserRanksPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserRanksPage(
            simLocation: simLocation,
            simLat: simLat,
            simLon: simLon,
          ),
        ),
      );

  void transitionToFriendsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FriendsPage(
            uid: uid,
          ),
        ),
      );

  void transitionToCurrentUserDetailsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrentUserDetailsPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToUserDetailsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsPage(
            currentUser: currentUser,
            webblenUser: webblenUser,
          ),
        ),
      );

  //REWARDS & ADS
  void transitionToCreateRewardPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRewardPage(),
        ),
      );

  void transitionToCreateAdPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAdPage(
            currentUser: currentUser,
          ),
        ),
      );

  //CHATS
  void transitionToChatInviteSharePage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatInviteSharePage(
            currentUser: currentUser,
            event: event,
          ),
        ),
      );

  void transitionToChatPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            currentUser: currentUser,
            chatKey: chatKey,
          ),
        ),
      );

  void transitionToChatIndexPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsIndexPage(
            currentUser: currentUser,
          ),
        ),
      );

  //COMMUNITIES
  void transitionToDiscoverPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiscoverPage(
            uid: uid,
            areaName: areaName,
            simLocation: simLocation,
            simLat: simLat,
            simLon: simLon,
          ),
        ),
      );

  void transitionToMyCommunitiesPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCommunitiesPage(
            uid: uid,
            action: action,
            areaName: areaName,
          ),
        ),
      );

  void transitionToNewCommunityPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateCommunityPage(
            areaName: areaName,
          ),
        ),
      );

  void transitionToChoosePostTypePage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoosePostTypePage(
            currentUser: currentUser,
            community: community,
          ),
        ),
      );

  void transitionToPostCommentsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityPostCommentsPage(
            currentUser: currentUser,
            newsPost: newsPost,
          ),
        ),
      );

  void transitionToCommunityProfilePage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityProfilePage(
            currentUser: currentUser,
            community: community,
          ),
        ),
      );

  void transitionToCommunityInvitePage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InviteMembersPage(
            currentUser: currentUser,
            community: community,
          ),
        ),
      );

  void transitionToCommunityCreatePostPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityCreatePostPage(
            currentUser: currentUser,
            community: community,
          ),
        ),
      );

  void transitionToComImagePage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddComImage(
            com: community,
          ),
        ),
      );

  void transitionToCommunitiesInAreaPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunitiesInAreaPage(
            currentUser: currentUser,
            action: action,
            areaName: areaName,
            communities: communities,
          ),
        ),
      );

  //SETINGS & NOTIFS
  void transitionToNotificationsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToSettingsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToWaitListPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinWaitlistPage(
            currentUser: currentUser,
          ),
        ),
      );

  //VOTING & REQUESTS
  void transitionToCommunityRequestPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityRequestsPage(
            currentUser: currentUser,
            areaName: areaName,
            simLat: simLat,
            simLon: simLon,
            simLocation: simLocation,
          ),
        ),
      );

  void transitionToCommunityRequestDetailsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityRequestDetailsPage(
            request: comRequest,
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToCreateCommunityRequestPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateCommunityRequestPage(
            currentUser: currentUser,
            areaName: areaName,
          ),
        ),
      );

  //WEBBLEN SCANNER
  void openWebblenScanner() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebblenScanner(
            currentUser: currentUser,
          ),
        ),
      );
}
