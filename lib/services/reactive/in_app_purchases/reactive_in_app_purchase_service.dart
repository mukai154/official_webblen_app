import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class ReactiveInAppPurchaseService with ReactiveServiceMixin {
  UserDataService _userDataService = locator<UserDataService>();

  final List<String> _productLists = ['webblen_1', 'webblen_5', 'webblen_25', 'webblen_50', 'webblen_100'];

  // ignore: cancel_subscriptions
  StreamSubscription? purchaseUpdatedSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription? purchaseErrorSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription? conectionSubscription;

  final _platformVersion = ReactiveValue<String>("Unknown");
  final _purchases = ReactiveValue<List<PurchasedItem>>([]);
  final _items = ReactiveValue<List<IAPItem>>([]);
  final _completingPurchase = ReactiveValue<bool>(false);

  String get platformVersion => _platformVersion.value;
  List<PurchasedItem> get purchases => _purchases.value;
  List<IAPItem> get items => _items.value;
  bool get completingPurchase => _completingPurchase.value;

  void updatePlatformVersion(String val) => _platformVersion.value = val;
  void updatePurchases(List<PurchasedItem> val) => _purchases.value = val;
  void updateItems(List<IAPItem> val) => _items.value = val;
  void updateCompletingPurchase(bool val) => _completingPurchase.value = val;

  reactiveInAppPurchaseService() {
    listenToReactiveValues([_completingPurchase, _platformVersion, _purchases, _items]);
  }

  Future<void> initializeFlutterIAP({required String uid}) async {
    String? platform;
    try {
      platform = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platform = 'Failed to get platform version.';
    }

    if (platform != null) {
      updatePlatformVersion(platformVersion);
    }

    await FlutterInappPurchase.instance.initConnection;

    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      String? productID = productItem!.productId;
      FlutterInappPurchase.instance.finishTransaction(productItem);
      completeInAppPurchase(productID, uid).then((completedPurchase) {
        if (completingPurchase) {
          HapticFeedback.mediumImpact();
          updateCompletingPurchase(false);
        }
      });
      print('purchase-updated: $productItem');
    });

    purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      if (completingPurchase) {
        updateCompletingPurchase(false);
      }
      print('purchase-error: $purchaseError');
    });

    getItems();
    getPurchases();
    getPurchaseHistory();
  }

  void getItems() async {
    List<IAPItem> allItems = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in allItems) {
      _items.value.add(item);
    }
  }

  void getPurchases() async {
    List<PurchasedItem>? allPurchases = await FlutterInappPurchase.instance.getAvailablePurchases();
    if (allPurchases != null) {
      for (var purchase in allPurchases) {
        _purchases.value.add(purchase);
      }
    }
  }

  void getPurchaseHistory() async {
    List<PurchasedItem>? purchaseHistory = await FlutterInappPurchase.instance.getPurchaseHistory();
    if (purchaseHistory != null) {
      for (var purchase in purchaseHistory) {
        this._purchases.value.add(purchase);
      }
    }
  }

  purchaseProduct(String prodID) {
    FlutterInappPurchase.instance.requestPurchase(prodID);
  }

  Future<bool> completeInAppPurchase(String? productID, String? uid) async {
    double depositAmount = 0.0;
    if (productID == 'webblen_1') {
      depositAmount = 1.00001;
    } else if (productID == 'webblen_5') {
      depositAmount = 5.00001;
    } else if (productID == 'webblen_25') {
      depositAmount = 25.00001;
    } else if (productID == 'webblen_50') {
      depositAmount = 50.00001;
    } else if (productID == 'webblen_100') {
      depositAmount = 100.00001;
    }
    bool depositedWBLN = await _userDataService.depositWebblen(uid: uid, amount: depositAmount);

    return depositedWBLN;
  }
}
