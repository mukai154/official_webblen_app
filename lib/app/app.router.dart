// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../ui/views/auth/auth_view.dart';
import '../ui/views/base/app_base_view.dart';
import '../ui/views/earnings/how_earnings_work/how_earnings_work_view.dart';
import '../ui/views/earnings/payout_methods/payout_methods_view.dart';
import '../ui/views/earnings/set_up_direct_deposit/set_up_direct_deposit_view.dart';
import '../ui/views/earnings/set_up_instant_deposit/set_up_instant_deposit_view.dart';
import '../ui/views/earnings/usd_balance_history/usd_balance_history_view.dart';
import '../ui/views/events/create_event_view/create_event_view.dart';
import '../ui/views/events/event_view/event_view.dart';
import '../ui/views/events/tickets/event_tickets/event_tickets_view.dart';
import '../ui/views/events/tickets/my_tickets/my_tickets_view.dart';
import '../ui/views/events/tickets/ticket_details/ticket_details_view.dart';
import '../ui/views/events/tickets/ticket_purchase/ticket_purchase_view.dart';
import '../ui/views/events/tickets/ticket_selection/ticket_selection_view.dart';
import '../ui/views/events/tickets/tickets_purchase_success/tickets_purchase_success_view.dart';
import '../ui/views/live_streams/create_live_stream_view/create_live_stream_view.dart';
import '../ui/views/live_streams/live_stream_details_view/live_stream_details_view.dart';
import '../ui/views/live_streams/live_stream_host_view/live_stream_host_view.dart';
import '../ui/views/live_streams/live_stream_viewer_view/live_stream_viewer_view.dart';
import '../ui/views/notifications/notifications_view.dart';
import '../ui/views/posts/create_post_view/create_post_view.dart';
import '../ui/views/posts/post_view/post_view.dart';
import '../ui/views/root/root_view.dart';
import '../ui/views/search/all_search_results/all_search_results_view.dart';
import '../ui/views/settings/settings_view.dart';
import '../ui/views/users/edit_profile/edit_profile_view.dart';
import '../ui/views/users/followers/user_followers_view.dart';
import '../ui/views/users/following/user_following_view.dart';
import '../ui/views/users/profile/user_profile_view.dart';
import '../ui/views/users/saved/saved_content_view.dart';

class Routes {
  static const String RootViewRoute = '/';
  static const String AuthViewRoute = '/login';
  static const String AppBaseViewRoute = '/home';
  static const String _PostViewRoute = '/post/:id';
  static String PostViewRoute({@required dynamic id}) => '/post/$id';
  static const String _CreatePostViewRoute = '/post/publish/:id/:promo';
  static String CreatePostViewRoute(
          {@required dynamic id, @required dynamic promo}) =>
      '/post/publish/$id/$promo';
  static const String _EventViewRoute = '/event/:id';
  static String EventViewRoute({@required dynamic id}) => '/event/$id';
  static const String _CreateEventViewRoute = '/event/publish/:id/:promo';
  static String CreateEventViewRoute(
          {@required dynamic id, @required dynamic promo}) =>
      '/event/publish/$id/$promo';
  static const String _LiveStreamViewRoute = '/stream/:id';
  static String LiveStreamViewRoute({@required dynamic id}) => '/stream/$id';
  static const String _CreateLiveStreamViewRoute = '/stream/publish/:id/:promo';
  static String CreateLiveStreamViewRoute(
          {@required dynamic id, @required dynamic promo}) =>
      '/stream/publish/$id/$promo';
  static const String _LiveStreamHostViewRoute = '/stream/host/:id';
  static String LiveStreamHostViewRoute({@required dynamic id}) =>
      '/stream/host/$id';
  static const String _LiveStreamViewerViewRoute = '/stream/viewer/:id';
  static String LiveStreamViewerViewRoute({@required dynamic id}) =>
      '/stream/viewer/$id';
  static const String _AllSearchResultsViewRoute = '/all_results/:term';
  static String AllSearchResultsViewRoute({@required dynamic term}) =>
      '/all_results/$term';
  static const String NotificationsViewRoute = '/notifications';
  static const String _UserProfileView = '/profile/:id';
  static String UserProfileView({@required dynamic id}) => '/profile/$id';
  static const String EditProfileViewRoute = '/edit_profile';
  static const String SavedContentViewRoute = '/saved';
  static const String _UserFollowersViewRoute = '/profile/followers/:id';
  static String UserFollowersViewRoute({@required dynamic id}) =>
      '/profile/followers/$id';
  static const String _UserFollowingViewRoute = '/profile/following/:id';
  static String UserFollowingViewRoute({@required dynamic id}) =>
      '/profile/following/$id';
  static const String SettingsViewRoute = '/settings';
  static const String MyTicketsViewRoute = '/wallet/my_tickets';
  static const String _EventTicketsViewRoute = '/wallet/my_tickets/event/:id';
  static String EventTicketsViewRoute({@required dynamic id}) =>
      '/wallet/my_tickets/event/$id';
  static const String _TicketDetailsViewRoute = '/tickets/view/:id';
  static String TicketDetailsViewRoute({@required dynamic id}) =>
      '/tickets/view/$id';
  static const String _TicketSelectionViewRoute = '/tickets/select/:id';
  static String TicketSelectionViewRoute({@required dynamic id}) =>
      '/tickets/select/$id';
  static const String _TicketPurchaseViewRoute =
      '/tickets/purchase/:id/:ticketsToPurchase';
  static String TicketPurchaseViewRoute(
          {@required dynamic id, @required dynamic ticketsToPurchase}) =>
      '/tickets/purchase/$id/$ticketsToPurchase';
  static const String _TicketsPurchaseSuccessViewRoute =
      '/ticket_purchase_success/:email';
  static String TicketsPurchaseSuccessViewRoute({@required dynamic email}) =>
      '/ticket_purchase_success/$email';
  static const String USDBalanceHistoryViewRoute = '/usd-balance-history';
  static const String PayoutMethodsViewRoute = '/payout-methods';
  static const String HowEarningsWorkViewRoute = '/how-earnings-work';
  static const String SetUpDirectDepositViewRoute = '/setup-direct-deposit';
  static const String SetUpInstantDepositViewRoute = '/setup-instant-deposit';
  static const all = <String>{
    RootViewRoute,
    AuthViewRoute,
    AppBaseViewRoute,
    _PostViewRoute,
    _CreatePostViewRoute,
    _EventViewRoute,
    _CreateEventViewRoute,
    _LiveStreamViewRoute,
    _CreateLiveStreamViewRoute,
    _LiveStreamHostViewRoute,
    _LiveStreamViewerViewRoute,
    _AllSearchResultsViewRoute,
    NotificationsViewRoute,
    _UserProfileView,
    EditProfileViewRoute,
    SavedContentViewRoute,
    _UserFollowersViewRoute,
    _UserFollowingViewRoute,
    SettingsViewRoute,
    MyTicketsViewRoute,
    _EventTicketsViewRoute,
    _TicketDetailsViewRoute,
    _TicketSelectionViewRoute,
    _TicketPurchaseViewRoute,
    _TicketsPurchaseSuccessViewRoute,
    USDBalanceHistoryViewRoute,
    PayoutMethodsViewRoute,
    HowEarningsWorkViewRoute,
    SetUpDirectDepositViewRoute,
    SetUpInstantDepositViewRoute,
  };
}

class StackedRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.RootViewRoute, page: RootView),
    RouteDef(Routes.AuthViewRoute, page: AuthView),
    RouteDef(Routes.AppBaseViewRoute, page: AppBaseView),
    RouteDef(Routes._PostViewRoute, page: PostView),
    RouteDef(Routes._CreatePostViewRoute, page: CreatePostView),
    RouteDef(Routes._EventViewRoute, page: EventView),
    RouteDef(Routes._CreateEventViewRoute, page: CreateEventView),
    RouteDef(Routes._LiveStreamViewRoute, page: LiveStreamDetailsView),
    RouteDef(Routes._CreateLiveStreamViewRoute, page: CreateLiveStreamView),
    RouteDef(Routes._LiveStreamHostViewRoute, page: LiveStreamHostView),
    RouteDef(Routes._LiveStreamViewerViewRoute, page: LiveStreamViewerView),
    RouteDef(Routes._AllSearchResultsViewRoute, page: AllSearchResultsView),
    RouteDef(Routes.NotificationsViewRoute, page: NotificationsView),
    RouteDef(Routes._UserProfileView, page: UserProfileView),
    RouteDef(Routes.EditProfileViewRoute, page: EditProfileView),
    RouteDef(Routes.SavedContentViewRoute, page: SavedContentView),
    RouteDef(Routes._UserFollowersViewRoute, page: UserFollowersView),
    RouteDef(Routes._UserFollowingViewRoute, page: UserFollowingView),
    RouteDef(Routes.SettingsViewRoute, page: SettingsView),
    RouteDef(Routes.MyTicketsViewRoute, page: MyTicketsView),
    RouteDef(Routes._EventTicketsViewRoute, page: EventTicketsView),
    RouteDef(Routes._TicketDetailsViewRoute, page: TicketDetailsView),
    RouteDef(Routes._TicketSelectionViewRoute, page: TicketSelectionView),
    RouteDef(Routes._TicketPurchaseViewRoute, page: TicketPurchaseView),
    RouteDef(Routes._TicketsPurchaseSuccessViewRoute,
        page: TicketsPurchaseSuccessView),
    RouteDef(Routes.USDBalanceHistoryViewRoute, page: USDBalanceHistoryView),
    RouteDef(Routes.PayoutMethodsViewRoute, page: PayoutMethodsView),
    RouteDef(Routes.HowEarningsWorkViewRoute, page: HowEarningsWorkView),
    RouteDef(Routes.SetUpDirectDepositViewRoute, page: SetupDirectDepositView),
    RouteDef(Routes.SetUpInstantDepositViewRoute,
        page: SetupInstantDepositView),
  ];
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    RootView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) => RootView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    AuthView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    AppBaseView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) => AppBaseView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    PostView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PostView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    CreatePostView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreatePostView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    EventView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    CreateEventView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateEventView(
          data.pathParams['id'].value,
          data.pathParams['promo'].value,
        ),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    LiveStreamDetailsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LiveStreamDetailsView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    CreateLiveStreamView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateLiveStreamView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    LiveStreamHostView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LiveStreamHostView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    LiveStreamViewerView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LiveStreamViewerView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    AllSearchResultsView: (data) {
      var args = data.getArgs<AllSearchResultsViewArguments>(
        orElse: () => AllSearchResultsViewArguments(),
      );
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AllSearchResultsView(searchTerm: args.searchTerm),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    NotificationsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NotificationsView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    UserProfileView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserProfileView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    EditProfileView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfileView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    SavedContentView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SavedContentView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    UserFollowersView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserFollowersView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    UserFollowingView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserFollowingView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    SettingsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    MyTicketsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MyTicketsView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    EventTicketsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventTicketsView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    TicketDetailsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TicketDetailsView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    TicketSelectionView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TicketSelectionView(data.pathParams['id'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    TicketPurchaseView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TicketPurchaseView(
          data.pathParams['id'].value,
          data.pathParams['ticketsToPurchase'].value,
        ),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    TicketsPurchaseSuccessView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TicketsPurchaseSuccessView(data.pathParams['email'].value),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    USDBalanceHistoryView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            USDBalanceHistoryView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    PayoutMethodsView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PayoutMethodsView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    HowEarningsWorkView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HowEarningsWorkView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    SetupDirectDepositView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SetupDirectDepositView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
    SetupInstantDepositView: (data) {
      return PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SetupInstantDepositView(),
        settings: data,
        transitionDuration: const Duration(milliseconds: 0),
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// AllSearchResultsView arguments holder class
class AllSearchResultsViewArguments {
  final String? searchTerm;
  AllSearchResultsViewArguments({this.searchTerm});
}
