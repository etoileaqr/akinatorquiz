import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionUtil {
  static Future<bool> checkConnectivityStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }
}
