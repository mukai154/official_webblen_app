import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/in_app_purchases/in_app_purchase_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

class PurchaseWebblenBottomSheetModel extends BaseViewModel {
  InAppPurchaseService? _inAppPurchaseService = locator<InAppPurchaseService>();
  WebblenBaseViewModel? webblenBaseViewModel = locator<WebblenBaseViewModel>();

  bool completingPurchase = false;
  StreamSubscription? _purchaseUpdatedSubscription;
  StreamSubscription? _purchaseErrorSubscription;
  StreamSubscription? _conectionSubscription;
  final List<String> _productLists = ['webblen_1', 'webblen_5', 'webblen_25', 'webblen_50', 'webblen_100'];
  String? _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  initialize() async {
    setBusy(true);
    await initializeFlutterIAP();
    setBusy(false);
  }

  initializeFlutterIAP() async {
    String? platformVersion;
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    await FlutterInappPurchase.instance.initConnection;
    _platformVersion = platformVersion;
    notifyListeners();

    // refresh items for android
    try {
      String? msg = await (FlutterInappPurchase.instance.consumeAllItems as FutureOr<String?>);
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      String? productID = productItem!.productId;
      FlutterInappPurchase.instance.finishTransaction(productItem);
      InAppPurchaseService().completeInAppPurchase(productID, webblenBaseViewModel!.uid).then((error) {
        if (error != null) {
          print(error);
        }
        if (completingPurchase) {
          HapticFeedback.mediumImpact();
          completingPurchase = false;
          notifyListeners();
        }
      });
      print('purchase-updated: $productItem');
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      if (completingPurchase) {
        completingPurchase = false;
        notifyListeners();
      }
      print('purchase-error: $purchaseError');
    });
    _getItems();
    _getPurchases();
    _getPurchaseHistory();
  }

  void purchaseProduct(String prodID) {
    completingPurchase = true;
    notifyListeners();
    FlutterInappPurchase.instance.requestPurchase(prodID);
  }

  void _getItems() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      this._items.add(item);
    }
  }

  Future _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }

    this._items = items;
    this._purchases = [];

    notifyListeners();
  }

  Future _getPurchases() async {
    List<PurchasedItem> items = await (FlutterInappPurchase.instance.getAvailablePurchases() as FutureOr<List<PurchasedItem>>);
    for (var item in items) {
      this._purchases.add(item);
    }

    this._items = [];
    this._purchases = items;
    notifyListeners();
  }

  Future _getPurchaseHistory() async {
    List<PurchasedItem> items = await (FlutterInappPurchase.instance.getPurchaseHistory() as FutureOr<List<PurchasedItem>>);
    for (var item in items) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    this._items = [];
    this._purchases = items;
    notifyListeners();
  }
}
