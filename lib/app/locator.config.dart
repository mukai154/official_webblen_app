// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

import '../services/auth/auth_service.dart';
import '../ui/views/home/tabs/check_in/check_in_view_model.dart';
import '../ui/views/home/tabs/home/home_view_model.dart';
import '../ui/views/home/tabs/messages/messages_view_model.dart';
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
  gh.lazySingleton<AuthService>(() => servicesModule.authService);
  gh.lazySingleton<DialogService>(() => servicesModule.dialogService);
  gh.lazySingleton<NavigationService>(() => servicesModule.navigationService);
  gh.lazySingleton<SnackbarService>(() => servicesModule.snackBarService);
  gh.lazySingleton<StripePaymentService>(() => servicesModule.stripePayment);
  gh.lazySingleton<ThemeService>(() => servicesModule.themeService);
  gh.lazySingleton<UserDataService>(() => servicesModule.userDataService);

  // Eager singletons must be registered in the right order
  gh.singleton<CheckInViewModel>(CheckInViewModel());
  gh.singleton<HomeViewModel>(HomeViewModel());
  gh.singleton<MessagesViewModel>(MessagesViewModel());
  gh.singleton<ProfileViewModel>(ProfileViewModel());
  gh.singleton<WalletViewModel>(WalletViewModel());
  return get;
}

class _$ServicesModule extends ServicesModule {
  @override
  AuthService get authService => AuthService();
  @override
  DialogService get dialogService => DialogService();
  @override
  NavigationService get navigationService => NavigationService();
  @override
  SnackbarService get snackBarService => SnackbarService();
  @override
  StripePaymentService get stripePayment => StripePaymentService();
  @override
  UserDataService get userDataService => UserDataService();
}
