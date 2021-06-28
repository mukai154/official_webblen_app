// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

import '../services/algolia/algolia_search_service.dart';
import '../services/auth/auth_service.dart';
import '../services/bottom_sheets/custom_bottom_sheets_service.dart';
import '../services/dialogs/custom_dialog_service.dart';
import '../services/dynamic_links/dynamic_link_service.dart';
import '../services/email/email_service.dart';
import '../services/firestore/common/firestore_storage_service.dart';
import '../services/firestore/data/activity_data_service.dart';
import '../services/firestore/data/comment_data_service.dart';
import '../services/firestore/data/content_gift_pool_data_service.dart';
import '../services/firestore/data/event_data_service.dart';
import '../services/firestore/data/gift_donation_service.dart';
import '../services/firestore/data/live_stream_chat_data_service.dart';
import '../services/firestore/data/live_stream_data_service.dart';
import '../services/firestore/data/notification_data_service.dart';
import '../services/firestore/data/platform_data_service.dart';
import '../services/firestore/data/post_data_service.dart';
import '../services/firestore/data/redeemed_reward_data_service.dart';
import '../services/firestore/data/ticket_distro_data_service.dart';
import '../services/firestore/data/user_data_service.dart';
import '../services/firestore/data/user_preference_data_service.dart';
import '../services/live_streaming/agora/agora_live_stream_service.dart';
import '../services/live_streaming/mux/mux_live_stream_service.dart';
import '../services/location/google_places_service.dart';
import '../services/location/location_service.dart';
import '../services/navigation/custom_navigation_service.dart';
import '../services/permission_handler/permission_handler_service.dart';
import '../services/reactive/content_filter/reactive_content_filter_service.dart';
import '../services/reactive/file_uploader/reactive_file_uploader_service.dart';
import '../services/reactive/in_app_purchases/reactive_in_app_purchase_service.dart';
import '../services/reactive/mini_video_player/reactive_mini_video_player_service.dart';
import '../services/reactive/user/reactive_user_service.dart';
import '../services/share/share_service.dart';
import '../services/stripe/stripe_connect_account_service.dart';
import '../services/stripe/stripe_payment_service.dart';
import '../ui/views/base/app_base_view_model.dart';
import '../ui/views/home/tabs/home/home_view_model.dart';
import '../ui/views/home/tabs/search/recent_search_view_model.dart';
import '../ui/views/home/tabs/wallet/wallet_view_model.dart';
import '../ui/widgets/home_feed/home_feed_model.dart';
import '../ui/widgets/mini_video_player/mini_video_player_view_model.dart';

final locator = StackedLocator.instance;

void setupLocator({String? environment, EnvironmentFilter? environmentFilter}) {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => ThemeService.getInstance());
  locator.registerLazySingleton(() => PermissionHandlerService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => CustomBottomSheetService());
  locator.registerLazySingleton(() => CustomDialogService());
  locator.registerLazySingleton(() => CustomNavigationService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => FirestoreStorageService());
  locator.registerLazySingleton(() => PlatformDataService());
  locator.registerLazySingleton(() => NotificationDataService());
  locator.registerLazySingleton(() => UserDataService());
  locator.registerLazySingleton(() => PostDataService());
  locator.registerLazySingleton(() => EventDataService());
  locator.registerLazySingleton(() => LiveStreamDataService());
  locator.registerLazySingleton(() => LiveStreamChatDataService());
  locator.registerLazySingleton(() => ContentGiftPoolDataService());
  locator.registerLazySingleton(() => RedeemedRewardDataService());
  locator.registerLazySingleton(() => TicketDistroDataService());
  locator.registerLazySingleton(() => CommentDataService());
  locator.registerLazySingleton(() => EmailService());
  locator.registerLazySingleton(() => StripePaymentService());
  locator.registerLazySingleton(() => StripeConnectAccountService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => GooglePlacesService());
  locator.registerLazySingleton(() => AlgoliaSearchService());
  locator.registerLazySingleton(() => DynamicLinkService());
  locator.registerLazySingleton(() => ShareService());
  locator.registerLazySingleton(() => ActivityDataService());
  locator.registerLazySingleton(() => UserPreferenceDataService());
  locator.registerLazySingleton(() => GiftDonationDataService());
  locator.registerLazySingleton(() => AgoraLiveStreamService());
  locator.registerLazySingleton(() => MuxLiveStreamService());
  locator.registerLazySingleton(() => MiniVideoPlayerViewModel());
  locator.registerLazySingleton(() => ReactiveUserService());
  locator.registerLazySingleton(() => ReactiveContentFilterService());
  locator.registerLazySingleton(() => ReactiveMiniVideoPlayerService());
  locator.registerLazySingleton(() => ReactiveFileUploaderService());
  locator.registerLazySingleton(() => ReactiveInAppPurchaseService());
  locator.registerSingleton(AppBaseViewModel());
  locator.registerSingleton(HomeViewModel());
  locator.registerSingleton(HomeFeedModel());
  locator.registerSingleton(RecentSearchViewModel());
  locator.registerSingleton(WalletViewModel());
}
