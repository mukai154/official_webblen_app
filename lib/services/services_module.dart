import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/firestore/notification_data_service.dart';
import 'package:webblen/services/firestore/platform_data_service.dart';
import 'package:webblen/services/firestore/post_data_service.dart';
import 'package:webblen/services/location/google_places_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

import 'auth/auth_service.dart';
import 'firestore/user_data_service.dart';

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
  PlatformDataService get platformDataService;
  @lazySingleton
  NotificationDataService get notificationDataService;
  @lazySingleton
  UserDataService get userDataService;
  @lazySingleton
  PostDataService get postDataService;
  @lazySingleton
  StripePaymentService get stripePaymentService;
  @lazySingleton
  LocationService get locationService;
  @lazySingleton
  GooglePlacesService get googlePlacesService;
  @lazySingleton
  AlgoliaSearchService get algoliaSearchService;
}
