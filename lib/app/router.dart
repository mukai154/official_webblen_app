import 'package:auto_route/auto_route_annotations.dart';
import 'package:webblen/ui/views/auth/auth_view.dart';
import 'package:webblen/ui/views/home/home_nav_view.dart';
import 'package:webblen/ui/views/root/root_view.dart';
import 'package:webblen/ui/views/settings/settings_view.dart';

///RUN "flutter pub run build_runner build" in Project Terminal to Generate Routes

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: RootView, initial: true, name: "RootViewRoute"),
    // //AUTHENTICATION
    MaterialRoute(page: AuthView, name: "AuthViewRoute"),
    // //ONBOARDING
    // MaterialRoute(page: OnboardingView, name: "OnboardingViewRoute"),
    // //HOME
    MaterialRoute(page: HomeNavView, name: "HomeNavViewRoute"),
    // //CAUSES
    // MaterialRoute(page: CauseView, name: "CauseViewRoute"),
    // MaterialRoute(page: CreateCauseView, name: "CreateCauseViewRoute"),
    // //SETTINGS
    MaterialRoute(page: SettingsView, name: "SettingsViewRoute"),
  ],
)
class $WebblenRouter {}
