import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class NewContentConfirmationBottomSheetModel extends StreamViewModel<double> {
  ///SERVICES
  AuthService? _authService = locator<AuthService>();
  UserDataService? _userDataService = locator<UserDataService>();

  ///CURRENT USER WBLN BALANCE
  double? webblenBalance;

  ///STREAM DATA
  @override
  void onData(double? data) {
    if (data != null) {
      webblenBalance = data;
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  Stream<double> get stream => streamWebblenBalance();

  Stream<double> streamWebblenBalance() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      String? uid = await _authService!.getCurrentUserID();
      var res = await _userDataService!.getWebblenUserByID(uid);
      if (res is String) {
        yield null;
      } else {
        yield res!.WBLN!;
      }
    }
  }
}
