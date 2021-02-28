import 'package:auto_route/auto_route_annotations.dart';
import 'package:webblen/ui/views/auth/auth_view.dart';
import 'package:webblen/ui/views/home/home_nav_view.dart';
import 'package:webblen/ui/views/home/tabs/profile/edit_profile/edit_profile_view.dart';
import 'package:webblen/ui/views/notifications/notifications_view.dart';
import 'package:webblen/ui/views/posts/create_post_view/create_post_view.dart';
import 'package:webblen/ui/views/posts/post_view/post_view.dart';
import 'package:webblen/ui/views/root/root_view.dart';
import 'package:webblen/ui/views/search/all_search_results/all_search_results_view.dart';
import 'package:webblen/ui/views/search/search_view.dart';
import 'package:webblen/ui/views/settings/settings_view.dart';
import 'package:webblen/ui/views/users/user_profile_view.dart';
import 'package:webblen/ui/views/wallet/redeemed_rewards/redeemed_rewards_view.dart';

///RUN "flutter pub run build_runner build --delete-conflicting-outputs" in Project Terminal to Generate Routes

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: RootView, initial: true, name: "RootViewRoute"),

    //AUTHENTICATION
    MaterialRoute(page: AuthView, name: "AuthViewRoute"),

    //ONBOARDING
    // MaterialRoute(page: OnboardingView, name: "OnboardingViewRoute"),

    // //HOME
    MaterialRoute(page: HomeNavView, name: "HomeNavViewRoute"),

    //POST
    MaterialRoute(page: PostView, name: "PostViewRoute"),
    MaterialRoute(page: CreatePostView, name: "CreatePostViewRoute"),

    //SEARCH
    MaterialRoute(page: SearchView, name: "SearchViewRoute"),
    MaterialRoute(page: AllSearchResultsView, name: "AllSearchResultsViewRoute"),

    //NOTIFICATIONS
    MaterialRoute(page: NotificationsView, name: "NotificationsViewRoute"),

    //PROFILE & SETTINGS
    MaterialRoute(page: UserProfileView, name: "UserProfileView"),
    MaterialRoute(page: EditProfileView, name: "EditProfileViewRoute"),
    MaterialRoute(page: SettingsView, name: "SettingsViewRoute"),

    //WALLET
    MaterialRoute(page: RedeemedRewardsView, name: 'RedeemedRewardsViewRoute'),
  ],
)
class $WebblenRouter {}
