import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_content_gift_pool.dart';
import 'package:webblen/models/webblen_gift_donation.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/gift_donation_service.dart';
import 'package:webblen/services/reactive/in_app_purchases/reactive_in_app_purchase_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

enum BottomSheetMode {
  rewards,
  refill,
}

class GiftWebblenBottomSheetModel extends ReactiveViewModel {
  ///SERVICES
  ReactiveInAppPurchaseService _reactiveInAppPurchaseService = locator<ReactiveInAppPurchaseService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  GiftDonationDataService _giftDonationsDataService = locator<GiftDonationDataService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///PURCHASE DATA
  bool get completingPurchase => _reactiveInAppPurchaseService.completingPurchase;

  ///SHEET MODE
  BottomSheetMode sheetMode = BottomSheetMode.rewards;

  ///CURRENT CONTENT GIFT POOL
  String? giftPoolID;
  late bool giftPoolExists;
  WebblenContentGiftPool? giftPool;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService, _reactiveInAppPurchaseService];

  initialize() async {
    await _reactiveInAppPurchaseService.initializeFlutterIAP(uid: user.id!);
  }

  void giftStreamer({
    required String contentID,
    required String hostID,
    required int giftID,
    required double giftAmount,
    required Function(SheetResponse) completer,
  }) async {
    HapticFeedback.mediumImpact();
    GiftDonation giftDonation = GiftDonation(
      senderUID: user.id,
      receiverUID: hostID,
      giftAmount: giftAmount,
      giftID: giftID,
      senderUsername: "@${user.username}",
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );

    await _giftDonationsDataService.sendGift(contentID: contentID, senderUID: user.id!, giftDonation: giftDonation, receiverUID: hostID);

    completer(SheetResponse());
  }

  toggleBottomSheetMode() {
    if (sheetMode == BottomSheetMode.rewards) {
      sheetMode = BottomSheetMode.refill;
    } else {
      sheetMode = BottomSheetMode.rewards;
    }
    notifyListeners();
  }

  purchaseProduct(String prodID) {
    _reactiveInAppPurchaseService.purchaseProduct(prodID);
  }
}
