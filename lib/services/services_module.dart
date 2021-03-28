import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/activity_data_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/content_gift_pool_data_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_chat_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/redeemed_reward_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_preference_data_service.dart';
import 'package:webblen/services/in_app_purchases/in_app_purchase_service.dart';
import 'package:webblen/services/location/google_places_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

import 'auth/auth_service.dart';
import 'firestore/data/user_data_service.dart';

///RUN "flutter pub run build_runner build --delete-conflicting-outputs" in Project Terminal to Generate Service Modules

@module
abstract class ServicesModule {
  @lazySingleton
  ThemeService get themeService => ThemeService.getInstance();
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  DialogService get dialogService;
  @lazySingleton
  BottomSheetService get bottomSheetService;
  @lazySingleton
  SnackbarService get snackBarService;
  @lazySingleton
  AuthService get authService;
  @lazySingleton
  FirestoreStorageService get firestoreStorageService;
  @lazySingleton
  PlatformDataService get platformDataService;
  @lazySingleton
  NotificationDataService get notificationDataService;
  @lazySingleton
  UserDataService get userDataService;
  @lazySingleton
  PostDataService get postDataService;
  @lazySingleton
  EventDataService get eventDataService;
  @lazySingleton
  LiveStreamDataService get liveStreamDataService;
  @lazySingleton
  LiveStreamChatDataService get liveStreamChatDataService;
  @lazySingleton
  ContentGiftPoolDataService get contentGiftPoolDataService;
  @lazySingleton
  TicketDistroDataService get ticketDistroDataService;
  @lazySingleton
  RedeemedRewardDataService get redeemedRewardDataService;
  @lazySingleton
  CommentDataService get commentDataService;
  @lazySingleton
  StripePaymentService get stripePaymentService;
  @lazySingleton
  StripeConnectAccountService get stripeConnectAccountService;
  @lazySingleton
  LocationService get locationService;
  @lazySingleton
  GooglePlacesService get googlePlacesService;
  @lazySingleton
  AlgoliaSearchService get algoliaSearchService;
  @lazySingleton
  DynamicLinkService get dynamicLinkService;
  @lazySingleton
  ShareService get shareService;
  @lazySingleton
  InAppPurchaseService get inAppPurchaseService;
  @lazySingleton
  ActivityDataService get activityDataService;
  @lazySingleton
  UserPreferenceDataService get userPreferenceDataService;
}
