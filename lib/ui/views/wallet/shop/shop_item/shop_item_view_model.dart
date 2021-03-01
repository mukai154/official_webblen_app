import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/enums/reward_type.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/reward_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/google_places_service.dart';

@singleton
class ShopItemViewModel extends BaseViewModel {
  RewardDataService _rewardDataService = locator<RewardDataService>();
  GooglePlacesService _googlePlacesService = locator<GooglePlacesService>();
  UserDataService _userDataService = locator<UserDataService>();

  WebblenUser user;
  WebblenReward reward;

  bool isLoading;
  String email;
  String address1;
  String address2;
  String cashRewardUsername;
  String cashRewardUsernameConfirmation;
  double purchaseTotal;
  String selectedSize = 'M';
  List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL'];
  final GlobalKey<FormState> merchFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> cashFormKey = GlobalKey<FormState>();

  void setAddress1(BuildContext context) async {
    address1 = await _googlePlacesService.openGoogleAutoComplete(context);
    notifyListeners();
  }

  void changeSelectedSize(String size) {
    selectedSize = size;
    notifyListeners();
  }

  ///INITIALIZE
  void initialize(BuildContext context) async {
    setBusy(true);

    Map<String, dynamic> args = RouteData.of(context).arguments;
    WebblenUser currentUser = args['currentUser'] ?? "";
    WebblenReward relevantReward = args['relevantReward'] ?? "";

    user = currentUser;
    reward = relevantReward;

    setBusy(false);
  }

  void purchaseReward(BuildContext context) {
    if (reward.rewardType == RewardType.webblenClothes) {
      submitMerchForm(context);
    } else {
      submitCashForm(context);
    }
  }

  void submitMerchForm(BuildContext context) {
    merchFormKey.currentState.save();
    if (email == null || !Strings().isEmailValid(email)) {
      showAlertDialog(
        context: context,
        message: "Email Invalid",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else if (address1 == null || address1.isEmpty) {
      showAlertDialog(
        context: context,
        message: "Address Required",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else {
      _rewardDataService.purchaseReward(user.id, reward.cost).then((e) {
        if (e == null) {
          _rewardDataService
              .purchaseMerchReward(
            uid: user.id,
            rewardTitle: reward.title,
            rewardID: reward.rewardID,
            size: selectedSize,
            email: email,
            address1: address1,
            address2: address2,
          )
              .then((e) async {
            if (e == null) {
              String res = await showAlertDialog(
                context: context,
                message: "Purchase Successful!",
                barrierDismissible: false,
                actions: [
                  AlertDialogAction(
                      label: "Ok", key: "ok", isDefaultAction: true),
                ],
              );
              if (res == "ok") {
                Navigator.of(context).pop();
              }
            } else {
              _userDataService.depositWebblen(reward.cost, user.id);
              showAlertDialog(
                context: context,
                message:
                    "There Was an Issue Completing Your Order. Please Try Again.",
                barrierDismissible: true,
                actions: [
                  AlertDialogAction(label: "Ok", isDefaultAction: true),
                ],
              );
            }
          });
        } else {
          showAlertDialog(
            context: context,
            message: "Insufficient Funds",
            barrierDismissible: true,
            actions: [
              AlertDialogAction(label: "Ok", isDefaultAction: true),
            ],
          );
        }
      });
    }
  }

  void submitCashForm(BuildContext context) {
    merchFormKey.currentState.save();
    if (!reward.title.contains("PayPal") && email == null ||
        !Strings().isEmailValid(email)) {
      showAlertDialog(
        context: context,
        message: "Email Invalid",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else if (cashRewardUsername == null || cashRewardUsername.isEmpty) {
      showAlertDialog(
        context: context,
        message: "Username Required",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else if (cashRewardUsername != cashRewardUsernameConfirmation) {
      showAlertDialog(
        context: context,
        message: "Usernames Do Not Match",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else {
      _rewardDataService.purchaseReward(user.id, reward.cost).then((e) {
        if (e == null) {
          _rewardDataService
              .purchaseCashReward(
            uid: user.id,
            rewardTitle: reward.title,
            rewardID: reward.rewardID,
            cashUsername: cashRewardUsername,
            email: email,
          )
              .then((e) async {
            if (e == null) {
              String res = await showAlertDialog(
                context: context,
                message: "Purchase Successful!",
                barrierDismissible: false,
                actions: [
                  AlertDialogAction(
                      label: "Ok", key: "ok", isDefaultAction: true),
                ],
              );
              if (res == "ok") {
                Navigator.of(context).pop();
              }
            } else {
              _userDataService.depositWebblen(reward.cost, user.id);
              showAlertDialog(
                context: context,
                message:
                    "There Was an Issue Completing Your Order. Please Try Again.",
                barrierDismissible: true,
                actions: [
                  AlertDialogAction(label: "Ok", isDefaultAction: true),
                ],
              );
            }
          });
        } else {
          showAlertDialog(
            context: context,
            message: "Insufficient Funds",
            barrierDismissible: true,
            actions: [
              AlertDialogAction(label: "Ok", isDefaultAction: true),
            ],
          );
        }
      });
    }
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }

}
