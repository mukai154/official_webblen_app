import 'package:auto_route/auto_route_annotations.dart';
import 'package:webblen/ui/root/root_view.dart';

///RUN "flutter pub run build_runner build" in Project Terminal to Generate Routes

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: RootView, initial: true, name: "RootViewRoute"),
    // //AUTHENTICATION
    // MaterialRoute(page: SignUpView, name: "SignUpViewRoute"),
    // MaterialRoute(page: SignInView, name: "SignInViewRoute"),
    // //ONBOARDING
    // MaterialRoute(page: OnboardingView, name: "OnboardingViewRoute"),
    // //HOME
    // MaterialRoute(page: HomeNavView, name: "HomeNavViewRoute"),
    // //CAUSES
    // MaterialRoute(page: CauseView, name: "CauseViewRoute"),
    // MaterialRoute(page: CreateCauseView, name: "CreateCauseViewRoute"),
    // //SETTINGS
    // MaterialRoute(page: SettingsView, name: "SettingsViewRoute"),
  ],
)
class $WebblenRouter {}
