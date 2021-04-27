// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

import '../services/algolia/algolia_search_service.dart';
import '../services/auth/auth_service.dart';
import '../services/dynamic_links/dynamic_link_service.dart';
import '../services/firestore/common/firestore_storage_service.dart';
import '../services/firestore/data/activity_data_service.dart';
import '../services/firestore/data/comment_data_service.dart';
import '../services/firestore/data/event_data_service.dart';
import '../services/firestore/data/live_stream_data_service.dart';
import '../services/firestore/data/notification_data_service.dart';
import '../services/firestore/data/platform_data_service.dart';
import '../services/firestore/data/post_data_service.dart';
import '../services/firestore/data/ticket_distro_data_service.dart';
import '../services/firestore/data/user_data_service.dart';
import '../services/firestore/data/user_preference_data_service.dart';
import '../services/location/google_places_service.dart';
import '../services/location/location_service.dart';
import '../services/share/share_service.dart';
import '../services/stripe/stripe_connect_account_service.dart';
import '../services/stripe/stripe_payment_service.dart';
import '../ui/views/base/webblen_base_view_model.dart';
import '../ui/views/home/tabs/home/home_view_model.dart';
import '../ui/views/home/tabs/search/recent_search_view_model.dart';
import '../ui/views/home/tabs/wallet/wallet_view_model.dart';

final locator = StackedLocator.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ThemeService.getInstance());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => FirestoreStorageService());
  locator.registerLazySingleton(() => PlatformDataService());
  locator.registerLazySingleton(() => NotificationDataService());
  locator.registerLazySingleton(() => UserDataService());
  locator.registerLazySingleton(() => PostDataService());
  locator.registerLazySingleton(() => EventDataService());
  locator.registerLazySingleton(() => LiveStreamDataService());
  locator.registerLazySingleton(() => TicketDistroDataService());
  locator.registerLazySingleton(() => CommentDataService());
  locator.registerLazySingleton(() => StripePaymentService());
  locator.registerLazySingleton(() => StripeConnectAccountService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => GooglePlacesService());
  locator.registerLazySingleton(() => AlgoliaSearchService());
  locator.registerLazySingleton(() => DynamicLinkService());
  locator.registerLazySingleton(() => ShareService());
  locator.registerLazySingleton(() => ActivityDataService());
  locator.registerLazySingleton(() => UserPreferenceDataService());
  locator.registerSingleton(WebblenBaseViewModel());
  locator.registerSingleton(HomeViewModel());
  locator.registerSingleton(RecentSearchViewModel());
  locator.registerSingleton(WalletViewModel());
}
