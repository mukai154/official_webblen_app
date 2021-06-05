import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/models/escrow_hot_wallet.dart';
import 'package:webblen/models/hot_wallet.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/firestore/data/escrow_hot_wallet_data_service.dart';
import 'package:webblen/services/firestore/data/hot_wallet_data_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/url_handler.dart';

class ProfileViewModel extends ReactiveViewModel {
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomBottomSheetService customBottomSheetService =
      locator<CustomBottomSheetService>();
  NavigationService _navigationService = locator<NavigationService>();
  HotWalletDataService _hotWalletDataService = locator<HotWalletDataService>();
  EscrowHotWalletDataService _escrowHotWalletDataService = locator<EscrowHotWalletDataService>();

  ///DATA
  WebblenUser get user => _reactiveUserService.user;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  void generateHotWallet() {
    _hotWalletDataService.createHotWallet();
  }

  void generateEscrowHotWallets() {
    _escrowHotWalletDataService.create100EscrowWallets();
  }

  //open user site
  openWebsite() {
    UrlHandler().launchInWebViewOrVC(_reactiveUserService.user.website!);
  }

  navigateToFollowers() {
    _navigationService.navigateTo(Routes.UserFollowersViewRoute(id: user.id));
  }

  navigateToFollowing() {
    _navigationService.navigateTo(Routes.UserFollowingViewRoute(id: user.id));
  }

  //show current user options
  showOptions() {
    customBottomSheetService.showCurrentUserOptions(user);
  }
}
