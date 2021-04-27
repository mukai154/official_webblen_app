import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class InAppPurchaseService {
  UserDataService? _userDataService = locator<UserDataService>();

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
    bool depositedWBLN = await _userDataService!.depositWebblen(uid: uid, amount: depositAmount);

    return depositedWBLN;
  }
}
