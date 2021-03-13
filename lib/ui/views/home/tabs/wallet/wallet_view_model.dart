import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';

@singleton
class WalletViewModel extends StreamViewModel<UserStripeInfo> {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();

  ///CURRENT USER
  String currentUID;
  UserStripeInfo _userStripeInfo;
  UserStripeInfo get userStripeInfo => _userStripeInfo;

  bool stripeAccountIsSetup = false;

  initialize(WebblenUser user) async {
    setBusy(true);
    currentUID = user.id;

    //get user stripe account
    String stripeUID = await _stripeConnectAccountService.getStripeUID(user.id);

    if (stripeUID != null) {
      stripeAccountIsSetup = true;
    }

    notifyListeners();
  }

  ///BOTTOM SHEETS
  //bottom sheet for new post, stream, or event
  showAddContentOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.addContent,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "new post") {
        navigateToCreatePostPage();
      } else if (res == "new stream") {
        //
      } else if (res == "new event") {
        navigateToCreateEventPage();
      }
      notifyListeners();
    }
  }

  //bottom sheet for post options
  showPostOptions() async {}

  ///STREAM DATA
  @override
  void onData(UserStripeInfo data) {
    if (data != null) {
      _userStripeInfo = data;
      print(data.toMap());
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  Stream<UserStripeInfo> get stream => streamUserStripeInfo();

  Stream<UserStripeInfo> streamUserStripeInfo() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      var res = await _stripeConnectAccountService.getStripeConnectAccountByUID(currentUID);
      if (res is String) {
        yield null;
      } else {
        yield res;
      }
    }
  }

  ///NAVIGATION
  navigateToCreatePostPage() {
    _navigationService.navigateTo(Routes.CreatePostViewRoute);
  }

  navigateToRedeemedRewardsView(WebblenUser user) {
    _navigationService.navigateTo(Routes.RedeemedRewardsViewRoute, arguments: {'currentUser': user});
  }

  navigateToCreateEventPage() {
    _navigationService.navigateTo(Routes.CreateEventViewRoute);
  }
}
