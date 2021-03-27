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
import '../services/firestore/data/comment_data_service.dart';
import '../services/firestore/data/content_gift_pool_data_service.dart';
import '../services/dynamic_links/dynamic_link_service.dart';
import '../services/firestore/data/event_data_service.dart';
import '../services/firestore/common/firestore_storage_service.dart';
import '../services/location/google_places_service.dart';
import '../ui/views/home/tabs/home/home_view_model.dart';
import '../services/firestore/data/live_stream_chat_data_service.dart';
import '../services/firestore/data/live_stream_data_service.dart';
import '../services/location/location_service.dart';
import '../services/firestore/data/notification_data_service.dart';
import '../services/firestore/data/platform_data_service.dart';
import '../services/firestore/data/post_data_service.dart';
import '../ui/views/home/tabs/profile/profile_view_model.dart';
import '../ui/views/home/tabs/search/recent_search_view_model.dart';
import '../services/firestore/data/redeemed_reward_data_service.dart';
import '../ui/views/wallet/redeemed_rewards/redeemed_rewards_view_model.dart';
import '../services/services_module.dart';
import '../services/share/share_service.dart';
import '../services/stripe/stripe_connect_account_service.dart';
import '../services/stripe/stripe_payment_service.dart';
import '../services/firestore/data/ticket_distro_data_service.dart';
import '../services/firestore/data/user_data_service.dart';
import '../ui/views/home/tabs/wallet/wallet_view_model.dart';
import '../ui/views/base/webblen_base_view_model.dart';

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
  gh.lazySingleton<CommentDataService>(() => servicesModule.commentDataService);
  gh.lazySingleton<ContentGiftPoolDataService>(
      () => servicesModule.contentGiftPoolDataService);
  gh.lazySingleton<DialogService>(() => servicesModule.dialogService);
  gh.lazySingleton<DynamicLinkService>(() => servicesModule.dynamicLinkService);
  gh.lazySingleton<EventDataService>(() => servicesModule.eventDataService);
  gh.lazySingleton<FirestoreStorageService>(
      () => servicesModule.firestoreStorageService);
  gh.lazySingleton<GooglePlacesService>(
      () => servicesModule.googlePlacesService);
  gh.lazySingleton<LiveStreamChatDataService>(
      () => servicesModule.liveStreamChatDataService);
  gh.lazySingleton<LiveStreamDataService>(
      () => servicesModule.liveStreamDataService);
  gh.lazySingleton<LocationService>(() => servicesModule.locationService);
  gh.lazySingleton<NavigationService>(() => servicesModule.navigationService);
  gh.lazySingleton<NotificationDataService>(
      () => servicesModule.notificationDataService);
  gh.lazySingleton<PlatformDataService>(
      () => servicesModule.platformDataService);
  gh.lazySingleton<PostDataService>(() => servicesModule.postDataService);
  gh.lazySingleton<RedeemedRewardDataService>(
      () => servicesModule.redeemedRewardDataService);
  gh.lazySingleton<ShareService>(() => servicesModule.shareService);
  gh.lazySingleton<SnackbarService>(() => servicesModule.snackBarService);
  gh.lazySingleton<StripeConnectAccountService>(
      () => servicesModule.stripeConnectAccountService);
  gh.lazySingleton<StripePaymentService>(
      () => servicesModule.stripePaymentService);
  gh.lazySingleton<ThemeService>(() => servicesModule.themeService);
  gh.lazySingleton<TicketDistroDataService>(
      () => servicesModule.ticketDistroDataService);
  gh.lazySingleton<UserDataService>(() => servicesModule.userDataService);
  gh.lazySingleton<WebblenBaseViewModel>(() => WebblenBaseViewModel());

  // Eager singletons must be registered in the right order
  gh.singleton<CheckInViewModel>(CheckInViewModel());
  gh.singleton<HomeViewModel>(HomeViewModel());
  gh.singleton<ProfileViewModel>(ProfileViewModel());
  gh.singleton<RecentSearchViewModel>(RecentSearchViewModel());
  gh.singleton<RedeemedRewardsViewModel>(RedeemedRewardsViewModel());
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
  CommentDataService get commentDataService => CommentDataService();
  @override
  ContentGiftPoolDataService get contentGiftPoolDataService =>
      ContentGiftPoolDataService();
  @override
  DialogService get dialogService => DialogService();
  @override
  DynamicLinkService get dynamicLinkService => DynamicLinkService();
  @override
  EventDataService get eventDataService => EventDataService();
  @override
  FirestoreStorageService get firestoreStorageService =>
      FirestoreStorageService();
  @override
  GooglePlacesService get googlePlacesService => GooglePlacesService();
  @override
  LiveStreamChatDataService get liveStreamChatDataService =>
      LiveStreamChatDataService();
  @override
  LiveStreamDataService get liveStreamDataService => LiveStreamDataService();
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
  RedeemedRewardDataService get redeemedRewardDataService =>
      RedeemedRewardDataService();
  @override
  ShareService get shareService => ShareService();
  @override
  SnackbarService get snackBarService => SnackbarService();
  @override
  StripeConnectAccountService get stripeConnectAccountService =>
      StripeConnectAccountService();
  @override
  StripePaymentService get stripePaymentService => StripePaymentService();
  @override
  TicketDistroDataService get ticketDistroDataService =>
      TicketDistroDataService();
  @override
  UserDataService get userDataService => UserDataService();
}
