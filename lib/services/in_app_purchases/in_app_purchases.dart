import 'package:webblen/firebase/data/user_data.dart';

class InAppPurchaseService {
  Future<String> completeInAppPurchase(String productID, String uid) async {
    String error;
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
    error = await WebblenUserData().depositWebblen(depositAmount, uid);
    return error;
  }
}
