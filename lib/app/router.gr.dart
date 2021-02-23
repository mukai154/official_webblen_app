// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../ui/views/auth/auth_view.dart';
import '../ui/views/home/home_nav_view.dart';
import '../ui/views/notifications/notifications_view.dart';
import '../ui/views/posts/create_post_view/create_post_view.dart';
import '../ui/views/posts/post_view/post_view.dart';
import '../ui/views/root/root_view.dart';
import '../ui/views/search/all_search_results/all_search_results_view.dart';
import '../ui/views/search/search_view.dart';
import '../ui/views/settings/settings_view.dart';
import '../ui/views/wallet_views/redeemed_rewards/redeemed_rewards_view.dart';

class Routes {
  static const String RootViewRoute = '/';
  static const String AuthViewRoute = '/auth-view';
  static const String HomeNavViewRoute = '/home-nav-view';
  static const String PostViewRoute = '/post-view';
  static const String CreatePostViewRoute = '/create-post-view';
  static const String SearchViewRoute = '/search-view';
  static const String AllSearchResultsViewRoute = '/all-search-results-view';
  static const String NotificationsViewRoute = '/notifications-view';
  static const String SettingsViewRoute = '/settings-view';
  static const String RedeemedRewardsViewRoute = '/redeemed-rewards-view';
  static const all = <String>{
    RootViewRoute,
    AuthViewRoute,
    HomeNavViewRoute,
    PostViewRoute,
    CreatePostViewRoute,
    SearchViewRoute,
    AllSearchResultsViewRoute,
    NotificationsViewRoute,
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
    RouteDef(Routes.HomeNavViewRoute, page: HomeNavView),
    RouteDef(Routes.PostViewRoute, page: PostView),
    RouteDef(Routes.CreatePostViewRoute, page: CreatePostView),
    RouteDef(Routes.SearchViewRoute, page: SearchView),
    RouteDef(Routes.AllSearchResultsViewRoute, page: AllSearchResultsView),
    RouteDef(Routes.NotificationsViewRoute, page: NotificationsView),
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
    HomeNavView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomeNavView(),
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
    SearchView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SearchView(),
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

/// AllSearchResultsView arguments holder class
class AllSearchResultsViewArguments {
  final String searchTerm;
  AllSearchResultsViewArguments({this.searchTerm});
}
