import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/purchased_ticket_data_service.dart';
import 'package:webblen/services/firestore/data/redeemed_reward_data_service.dart';
import 'package:webblen/services/firestore/data/reward_data_service.dart';
import 'package:webblen/services/location/google_places_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
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
  RedeemedRewardDataService get redeemedRewardDataService;
  @lazySingleton
  RewardDataService get rewardDataService;
  @lazySingleton
  CommentDataService get commentDataService;
  @lazySingleton
  PurchasedTicketDataService get purchasedTicketDataService;
  @lazySingleton
  EventDataService get eventDataService;
  @lazySingleton
  StripePaymentService get stripePaymentService;
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
}
