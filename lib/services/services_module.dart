import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

import 'auth/auth_service.dart';
import 'firestore/user_data_service.dart';

///RUN "flutter pub run build_runner build" in Project Terminal to Generate Service Modules

@module
abstract class ServicesModule {
  @lazySingleton
  ThemeService get themeService => ThemeService.getInstance();
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  DialogService get dialogService;
  @lazySingleton
  SnackbarService get snackBarService;
  @lazySingleton
  AuthService get authService;
  @lazySingleton
  UserDataService get userDataService;
  @lazySingleton
  StripePaymentService get stripePayment;
}
