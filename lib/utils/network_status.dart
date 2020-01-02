import 'package:connectivity/connectivity.dart';

class NetworkStatus {

  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print('mobile');
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print('wifi');
      return true;
    }
    return false;
  }

}
