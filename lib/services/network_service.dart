import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class NetworkService {
  Future<bool> hasInternetConnection() async {
    try {
      final dynamic result = await Connectivity().checkConnectivity();

      if (result is ConnectivityResult) {
        return result != ConnectivityResult.none;
      }

      if (result is List<ConnectivityResult>) {
        return result.any(
          (ConnectivityResult item) => item != ConnectivityResult.none,
        );
      }

      return false;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isConnected() {
    return hasInternetConnection();
  }
}
