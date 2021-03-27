// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../ui/views/auth/auth_view.dart';
import '../ui/views/base/webblen_base_view.dart';
import '../ui/views/events/create_event_view/create_event_view.dart';
import '../ui/views/events/event_view/event_view.dart';
import '../ui/views/live_streams/create_live_stream_view/create_live_stream_view.dart';
import '../ui/views/live_streams/live_stream_details_view/live_stream_details_view.dart';
import '../ui/views/live_streams/live_stream_host_view/live_stream_host_view.dart';
import '../ui/views/notifications/notifications_view.dart';
import '../ui/views/posts/create_post_view/create_post_view.dart';
import '../ui/views/posts/post_view/post_view.dart';
import '../ui/views/root/root_view.dart';
import '../ui/views/search/all_search_results/all_search_results_view.dart';
import '../ui/views/search/search_view.dart';
import '../ui/views/settings/settings_view.dart';
import '../ui/views/users/edit_profile/edit_profile_view.dart';
import '../ui/views/users/followers/user_followers_view.dart';
import '../ui/views/users/following/user_following_view.dart';
import '../ui/views/users/profile/user_profile_view.dart';
import '../ui/views/wallet/redeemed_rewards/redeemed_rewards_view.dart';

class Routes {
  static const String RootViewRoute = '/';
  static const String AuthViewRoute = '/auth-view';
  static const String WebblenBaseViewRoute = '/webblen-base-view';
  static const String PostViewRoute = '/post-view';
  static const String CreatePostViewRoute = '/create-post-view';
  static const String EventViewRoute = '/event-view';
  static const String CreateEventViewRoute = '/create-event-view';
  static const String LiveStreamViewRoute = '/live-stream-details-view';
  static const String CreateLiveStreamViewRoute = '/create-live-stream-view';
  static const String LiveStreamHostViewRoute = '/live-stream-host-view';
  static const String SearchViewRoute = '/search-view';
  static const String AllSearchResultsViewRoute = '/all-search-results-view';
  static const String NotificationsViewRoute = '/notifications-view';
  static const String UserProfileView = '/user-profile-view';
  static const String EditProfileViewRoute = '/edit-profile-view';
  static const String UserFollowersViewRoute = '/user-followers-view';
  static const String UserFollowingViewRoute = '/user-following-view';
  static const String SettingsViewRoute = '/settings-view';
  static const String RedeemedRewardsViewRoute = '/redeemed-rewards-view';
  static const all = <String>{
    RootViewRoute,
    AuthViewRoute,
    WebblenBaseViewRoute,
    PostViewRoute,
    CreatePostViewRoute,
    EventViewRoute,
    CreateEventViewRoute,
    LiveStreamViewRoute,
    CreateLiveStreamViewRoute,
    LiveStreamHostViewRoute,
    SearchViewRoute,
    AllSearchResultsViewRoute,
    NotificationsViewRoute,
    UserProfileView,
    EditProfileViewRoute,
    UserFollowersViewRoute,
    UserFollowingViewRoute,
    SettingsViewRoute,
    RedeemedRewardsViewRoute,
  };
}

class WebblenRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.RootViewRoute, page: RootView),
    RouteDef(Routes.AuthViewRoute, page: AuthView),
    RouteDef(Routes.WebblenBaseViewRoute, page: WebblenBaseView),
    RouteDef(Routes.PostViewRoute, page: PostView),
    RouteDef(Routes.CreatePostViewRoute, page: CreatePostView),
    RouteDef(Routes.EventViewRoute, page: EventView),
    RouteDef(Routes.CreateEventViewRoute, page: CreateEventView),
    RouteDef(Routes.LiveStreamViewRoute, page: LiveStreamDetailsView),
    RouteDef(Routes.CreateLiveStreamViewRoute, page: CreateLiveStreamView),
    RouteDef(Routes.LiveStreamHostViewRoute, page: LiveStreamHostView),
    RouteDef(Routes.SearchViewRoute, page: SearchView),
    RouteDef(Routes.AllSearchResultsViewRoute, page: AllSearchResultsView),
    RouteDef(Routes.NotificationsViewRoute, page: NotificationsView),
    RouteDef(Routes.UserProfileView, page: UserProfileView),
    RouteDef(Routes.EditProfileViewRoute, page: EditProfileView),
    RouteDef(Routes.UserFollowersViewRoute, page: UserFollowersView),
    RouteDef(Routes.UserFollowingViewRoute, page: UserFollowingView),
    RouteDef(Routes.SettingsViewRoute, page: SettingsView),
    RouteDef(Routes.RedeemedRewardsViewRoute, page: RedeemedRewardsView),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    RootView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RootView(),
        settings: data,
      );
    },
    AuthView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AuthView(),
        settings: data,
      );
    },
    WebblenBaseView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => WebblenBaseView(),
        settings: data,
      );
    },
    PostView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => PostView(),
        settings: data,
      );
    },
    CreatePostView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreatePostView(),
        settings: data,
      );
    },
    EventView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EventView(),
        settings: data,
      );
    },
    CreateEventView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreateEventView(),
        settings: data,
      );
    },
    LiveStreamDetailsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LiveStreamDetailsView(),
        settings: data,
      );
    },
    CreateLiveStreamView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreateLiveStreamView(),
        settings: data,
      );
    },
    LiveStreamHostView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LiveStreamHostView(),
        settings: data,
      );
    },
    SearchView: (data) {
      final args = data.getArgs<SearchViewArguments>(
        orElse: () => SearchViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => SearchView(term: args.term),
        settings: data,
      );
    },
    AllSearchResultsView: (data) {
      final args = data.getArgs<AllSearchResultsViewArguments>(
        orElse: () => AllSearchResultsViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AllSearchResultsView(searchTerm: args.searchTerm),
        settings: data,
      );
    },
    NotificationsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => NotificationsView(),
        settings: data,
      );
    },
    UserProfileView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => UserProfileView(),
        settings: data,
      );
    },
    EditProfileView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditProfileView(),
        settings: data,
      );
    },
    UserFollowersView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => UserFollowersView(),
        settings: data,
      );
    },
    UserFollowingView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => UserFollowingView(),
        settings: data,
      );
    },
    SettingsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SettingsView(),
        settings: data,
      );
    },
    RedeemedRewardsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RedeemedRewardsView(),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// SearchView arguments holder class
class SearchViewArguments {
  final String term;
  SearchViewArguments({this.term});
}

/// AllSearchResultsView arguments holder class
class AllSearchResultsViewArguments {
  final String searchTerm;
  AllSearchResultsViewArguments({this.searchTerm});
}
