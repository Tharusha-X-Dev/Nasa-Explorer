class NetworkErrorUtils {
  static const String noInternetMessage = 'No internet connection';

  static bool isOfflineError(Object error) {
    return error.toString().toLowerCase().contains(
      noInternetMessage.toLowerCase(),
    );
  }
}
