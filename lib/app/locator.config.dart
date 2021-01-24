// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

import '../services/algolia/algolia_search_service.dart';
import '../services/auth/auth_service.dart';
import '../ui/views/home/tabs/check_in/check_in_view_model.dart';
import '../ui/views/home/tabs/explore/explore_view_model.dart';
import '../services/location/google_places_service.dart';
import '../ui/views/home/tabs/home/home_view_model.dart';
import '../services/location/location_service.dart';
import '../ui/views/home/tabs/messages/messages_view_model.dart';
import '../ui/views/home/tabs/home/tabs/news_posts/news_posts_view_model.dart';
import '../services/firestore/notification_data_service.dart';
import '../services/firestore/platform_data_service.dart';
import '../services/firestore/post_data_service.dart';
import '../ui/views/home/tabs/profile/profile_view_model.dart';
import '../services/services_module.dart';
import '../services/stripe/stripe_payment_service.dart';
import '../services/firestore/user_data_service.dart';
import '../ui/views/home/tabs/wallet/wallet_view_model.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);
  final servicesModule = _$ServicesModule();
  gh.lazySingleton<AlgoliaSearchService>(
      () => servicesModule.algoliaSearchService);
  gh.lazySingleton<AuthService>(() => servicesModule.authService);
  gh.lazySingleton<BottomSheetService>(() => servicesModule.bottomSheetService);
  gh.lazySingleton<DialogService>(() => servicesModule.dialogService);
  gh.lazySingleton<GooglePlacesService>(
      () => servicesModule.googlePlacesService);
  gh.lazySingleton<LocationService>(() => servicesModule.locationService);
  gh.lazySingleton<NavigationService>(() => servicesModule.navigationService);
  gh.lazySingleton<NotificationDataService>(
      () => servicesModule.notificationDataService);
  gh.lazySingleton<PlatformDataService>(
      () => servicesModule.platformDataService);
  gh.lazySingleton<PostDataService>(() => servicesModule.postDataService);
  gh.lazySingleton<SnackbarService>(() => servicesModule.snackBarService);
  gh.lazySingleton<StripePaymentService>(
      () => servicesModule.stripePaymentService);
  gh.lazySingleton<ThemeService>(() => servicesModule.themeService);
  gh.lazySingleton<UserDataService>(() => servicesModule.userDataService);

  // Eager singletons must be registered in the right order
  gh.singleton<CheckInViewModel>(CheckInViewModel());
  gh.singleton<ExploreViewModel>(ExploreViewModel());
  gh.singleton<HomeViewModel>(HomeViewModel());
  gh.singleton<MessagesViewModel>(MessagesViewModel());
  gh.singleton<NewsPostsViewModel>(NewsPostsViewModel());
  gh.singleton<ProfileViewModel>(ProfileViewModel());
  gh.singleton<WalletViewModel>(WalletViewModel());
  return get;
}

class _$ServicesModule extends ServicesModule {
  @override
  AlgoliaSearchService get algoliaSearchService => AlgoliaSearchService();
  @override
  AuthService get authService => AuthService();
  @override
  BottomSheetService get bottomSheetService => BottomSheetService();
  @override
  DialogService get dialogService => DialogService();
  @override
  GooglePlacesService get googlePlacesService => GooglePlacesService();
  @override
  LocationService get locationService => LocationService();
  @override
  NavigationService get navigationService => NavigationService();
  @override
  NotificationDataService get notificationDataService =>
      NotificationDataService();
  @override
  PlatformDataService get platformDataService => PlatformDataService();
  @override
  PostDataService get postDataService => PostDataService();
  @override
  SnackbarService get snackBarService => SnackbarService();
  @override
  StripePaymentService get stripePaymentService => StripePaymentService();
  @override
  UserDataService get userDataService => UserDataService();
}
