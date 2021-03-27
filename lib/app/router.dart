import 'package:auto_route/auto_route_annotations.dart';
import 'package:webblen/ui/views/auth/auth_view.dart';
import 'package:webblen/ui/views/base/webblen_base_view.dart';
import 'package:webblen/ui/views/events/create_event_view/create_event_view.dart';
import 'package:webblen/ui/views/events/event_view/event_view.dart';
import 'package:webblen/ui/views/live_streams/create_live_stream_view/create_live_stream_view.dart';
import 'package:webblen/ui/views/live_streams/live_stream_details_view/live_stream_details_view.dart';
import 'package:webblen/ui/views/live_streams/live_stream_host_view/live_stream_host_view.dart';
import 'package:webblen/ui/views/notifications/notifications_view.dart';
import 'package:webblen/ui/views/posts/create_post_view/create_post_view.dart';
import 'package:webblen/ui/views/posts/post_view/post_view.dart';
import 'package:webblen/ui/views/root/root_view.dart';
import 'package:webblen/ui/views/search/all_search_results/all_search_results_view.dart';
import 'package:webblen/ui/views/search/search_view.dart';
import 'package:webblen/ui/views/settings/settings_view.dart';
import 'package:webblen/ui/views/users/edit_profile/edit_profile_view.dart';
import 'package:webblen/ui/views/users/followers/user_followers_view.dart';
import 'package:webblen/ui/views/users/following/user_following_view.dart';
import 'package:webblen/ui/views/users/profile/user_profile_view.dart';
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

    //HOME
    MaterialRoute(page: WebblenBaseView, name: "WebblenBaseViewRoute"),

    //POST
    MaterialRoute(page: PostView, name: "PostViewRoute"),
    MaterialRoute(page: CreatePostView, name: "CreatePostViewRoute"),

    //EVENT
    MaterialRoute(page: EventView, name: "EventViewRoute"),
    MaterialRoute(page: CreateEventView, name: "CreateEventViewRoute"),

    //STREAM
    MaterialRoute(page: LiveStreamDetailsView, name: "LiveStreamViewRoute"),
    MaterialRoute(page: CreateLiveStreamView, name: "CreateLiveStreamViewRoute"),
    MaterialRoute(page: LiveStreamHostView, name: "LiveStreamHostViewRoute"),
    //MaterialRoute(page: LiveStreamViewerView, name: "LiveStreamViewerViewRoute"),
    //SEARCH
    MaterialRoute(page: SearchView, name: "SearchViewRoute"),
    MaterialRoute(page: AllSearchResultsView, name: "AllSearchResultsViewRoute"),

    //NOTIFICATIONS
    MaterialRoute(page: NotificationsView, name: "NotificationsViewRoute"),

    //USER PROFILE & SETTINGS
    MaterialRoute(page: UserProfileView, name: "UserProfileView"),
    MaterialRoute(page: EditProfileView, name: "EditProfileViewRoute"),
    MaterialRoute(page: UserFollowersView, name: "UserFollowersViewRoute"),
    MaterialRoute(page: UserFollowingView, name: "UserFollowingViewRoute"),
    MaterialRoute(page: SettingsView, name: "SettingsViewRoute"),

    //WALLET
    MaterialRoute(page: RedeemedRewardsView, name: 'RedeemedRewardsViewRoute'),
  ],
)
class $WebblenRouter {}
