import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/firestore/data/user_algorand_account_data.dart';
import 'package:webblen/services/nft/nft_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/url_handler.dart';

class ProfileViewModel extends ReactiveViewModel {
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomBottomSheetService customBottomSheetService =
      locator<CustomBottomSheetService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserAlgorandAccountDataService _userAlgorandAccountDataService =
      locator<UserAlgorandAccountDataService>();
  NftService _nftService = locator<NftService>();

  ///DATA
  WebblenUser get user => _reactiveUserService.user;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  void mintNftTest() async {
    await _nftService.mintNft(
      creatorUid: user.id!,
      assetName: 'mintTest30',
    );
  }

  void buyNftTest() async {
    await _nftService.purchaseNft(
      assetId: 18234990,
      userUid: 'axskbNqJAlbKh6RNJ6gmZddeYV33',
      businessUid: '6vltcXAjsfYVy9j1WxOsqbnnQOs1',
      webblenPriceInMicroWebblen: 1000000,
    );
  }

  void redeemNftTest() async {
    await _nftService.redeemNft(
      assetId: 18234990,
      userUid: '6vltcXAjsfYVy9j1WxOsqbnnQOs1',
      businessUid: 'axskbNqJAlbKh6RNJ6gmZddeYV33',
    );
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

  navigateToEditProfile() {
    _navigationService.navigateTo(Routes.EditProfileViewRoute);
  }

  //show current user options
  showOptions() {
    customBottomSheetService.showCurrentUserOptions(user);
  }
}
