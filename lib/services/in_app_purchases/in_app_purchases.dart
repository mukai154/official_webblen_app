import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:webblen/firebase/data/user_data.dart';

class InAppPurchaseService {
  InAppPurchaseConnection iap = InAppPurchaseConnection.instance;
  bool available = true;
  Set<String> prodIDs = Set.from(['webblen_1', 'webblen_5']);

  Stream<List<PurchaseDetails>> streamPurchases() {
    return iap.purchaseUpdatedStream;
  }

  Future<bool> checkIfPurchasesAreAvailable() async {
    bool isAvailable = await InAppPurchaseConnection.instance.isAvailable();
    return isAvailable;
  }

  Future<List<ProductDetails>> loadProductsForSale(InAppPurchaseConnection inAppPurchaseConnection) async {
    List<ProductDetails> products = [];
    ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(prodIDs);
    if (response.notFoundIDs.isNotEmpty) {
      print('product load error');
    } else {
      products = response.productDetails;
      print('loaded products: ${products.length}');
    }
    return products;
  }

  Future<List<PurchaseDetails>> loadPastPurchases(InAppPurchaseConnection iap) async {
    List<PurchaseDetails> purchaseHistory;
    loadProductsForSale(iap);
    purchaseHistory = await iap.purchaseUpdatedStream.first;
    print(purchaseHistory);
    for (PurchaseDetails purchase in purchaseHistory) {
      final pending = Platform.isIOS ? purchase.pendingCompletePurchase : !purchase.billingClientPurchase.isAcknowledged;
      print('pending status $pending');
      if (pending) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }

    return purchaseHistory;
  }

  Future<String> purchaseProduct(ProductDetails prod, InAppPurchaseConnection iap, String uid) async {
    String error;
    double purchasedWebblen;
    if (prod.id == 'webblen_1') {
      purchasedWebblen = 1.00001;
    } else if (prod.id == 'webblen_5') {
      purchasedWebblen = 5.00001;
    }
    if (purchasedWebblen != null) {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
      await iap.buyConsumable(purchaseParam: purchaseParam).catchError((e) async {
        error = e.toString();
      });
      print(error);
    }
    return error;
  }

  Future<PurchaseDetails> hasPurchasedProduct(String productID, List<PurchaseDetails> purchases) async {
    return purchases.firstWhere((purchase) => purchase.productID == productID, orElse: () => null);
  }

  Future<String> verifyPurchase(String uid, String prodID, List<PurchaseDetails> purchases, InAppPurchaseConnection iap) async {
    String error;
    await WebblenUserData().depositWebblen(1.00001, uid);
    List<PurchaseDetails> purchases = await loadPastPurchases(iap);
    PurchaseDetails purchase = await hasPurchasedProduct(prodID, purchases);
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      error = await WebblenUserData().depositWebblen(1.00001, uid);
    }
    return error;
  }
}
