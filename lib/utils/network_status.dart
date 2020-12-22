import 'dart:io';

class NetworkStatus {
  Future<bool> isConnected() async {
    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      print('not connected');
    }
    return isConnected;
  }
}
