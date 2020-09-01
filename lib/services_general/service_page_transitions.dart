import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:webblen/home_page.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/pages/earnings_pages/bank_account_details_page.dart';
import 'package:webblen/pages/earnings_pages/debit_card_details_page.dart';
import 'package:webblen/pages/earnings_pages/earnings_info_page.dart';
import 'package:webblen/pages/earnings_pages/earnings_page.dart';
import 'package:webblen/pages/earnings_pages/payments_history_page.dart';
import 'package:webblen/pages/earnings_pages/payout_methods_page.dart';
import 'package:webblen/pages/earnings_pages/set_up_direct_deposit_page.dart';
import 'package:webblen/pages/earnings_pages/set_up_instant_deposit_page.dart';
import 'package:webblen/pages/event_pages/create_event_page.dart';
import 'package:webblen/pages/event_pages/digital_event_page.dart';
import 'package:webblen/pages/event_pages/event_attendees_page.dart';
import 'package:webblen/pages/event_pages/event_check_in_page.dart';
import 'package:webblen/pages/event_pages/event_details_page.dart';
import 'package:webblen/pages/home_pages/notifications_page.dart';
import 'package:webblen/pages/home_pages/wallet_page.dart';
import 'package:webblen/pages/ticket_pages/event_tickets_page.dart';
import 'package:webblen/pages/ticket_pages/ticket_info_page.dart';
import 'package:webblen/pages/ticket_pages/ticket_purchase_page.dart';
import 'package:webblen/pages/ticket_pages/ticket_selection_page.dart';
import 'package:webblen/pages/user_pages/friends_page.dart';
import 'package:webblen/pages/user_pages/reward_payout_page.dart';
import 'package:webblen/pages/user_pages/search_page.dart';
import 'package:webblen/pages/user_pages/settings_page.dart';
import 'package:webblen/pages/user_pages/shop_page.dart';
import 'package:webblen/pages/user_pages/transaction_history_page.dart';
import 'package:webblen/pages/user_pages/user_page.dart';
import 'package:webblen/pages/user_pages/users_search_page.dart';
import 'package:webblen/utils/ticket_scanner.dart';
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
  final WebblenUser webblenUser;
  final WebblenUser currentUser;
  final WebblenChat chat;
  final String chatKey;
  final String peerUsername;
  final String peerProfilePic;
  final String profilePicUrl;
  final WebblenReward reward;
  final WebblenEvent event;
  final String eventID;
  final bool eventIsLive;
  final Community community;
  final List<Community> communities;
  final String newEventOrPost;
  final bool viewingMembersOrAttendees;
  final double lat;
  final double lon;
  final List<Map<String, dynamic>> ticketsToPurchase;
  final List eventFees;
  final ClientRole clientRole;
  final bool isStream;

  PageTransitionService({
    this.isStream,
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
    this.reward,
    this.event,
    this.eventID,
    this.userIDs,
    this.eventIsLive,
    this.community,
    this.areaName,
    this.newEventOrPost,
    this.viewingMembersOrAttendees,
    this.lat,
    this.lon,
    this.communities,
    this.ticketsToPurchase,
    this.eventFees,
    this.clientRole,
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

  void transitionToSim() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
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
  void transitionToCreateEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateEventPage(
            eventID: eventID,
            isStream: isStream,
          ),
        ),
      );

  void transitionToEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(
            eventID: eventID,
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToDigitalEventPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DigitalEventPage(
            currentUser: currentUser,
            event: event,
            role: clientRole,
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
            eventID: eventID,
          ),
        ),
      );

  void transitionToTicketSelectionPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketSelectionPage(
            currentUser: currentUser,
            event: event,
          ),
        ),
      );

  void transitionToTicketPurchasePage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketPurchasePage(
            currentUser: currentUser,
            event: event,
            ticketsToPurchase: ticketsToPurchase,
            eventFees: eventFees,
          ),
        ),
      );

  void transitionToEventTicketsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletEventTicketsPage(
            eventID: eventID,
            currentUser: currentUser,
          ),
        ),
      );

  void openTicketScanner() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketScanner(
            currentUser: currentUser,
            event: event,
          ),
        ),
      );

  void transitionToTicketInfoPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketInfoPage(),
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

  void transitionToEarningsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EarningsPage(
            currentUser: currentUser,
          ),
        ),
      );

  void transitionToEarningsInfoPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EarningsInfoPage(),
        ),
      );

  void transitionToPayoutMethodsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayoutMethodsPage(currentUser: currentUser),
        ),
      );

  void transitionToPaymentHistoryPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentHistoryPage(),
        ),
      );

  void transitionToBankAccoutDetailsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BankAccountDetailsPage(currentUser: currentUser),
        ),
      );

  void transitionToSetUpDirectDepositPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetUpDirectDepositPage(currentUser: currentUser),
        ),
      );

  void transitionToSetUpInstantDepositPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetUpInstantDepositPage(currentUser: currentUser),
        ),
      );

  void transitionToDebitCardDetailsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DebitCardDetailsPage(currentUser: currentUser),
        ),
      );

  //USERS
  void transitionToFriendsPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FriendsPage(
            uid: uid,
          ),
        ),
      );

  void transitionToUserPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserPage(
            currentUser: currentUser,
            webblenUser: webblenUser,
          ),
        ),
      );

  void transitionToCurrentUserPage() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrentUserPage(
            currentUser: currentUser,
            webblenUser: webblenUser,
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
