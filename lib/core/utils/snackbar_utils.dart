import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showFavoriteStateChanged(BuildContext context, bool isFavorite) {
    showInfo(
      context,
      isFavorite ? 'Added to favorites' : 'Removed from favorites',
    );
  }

  static void showVideoOpenError(BuildContext context) {
    showInfo(context, 'Unable to open video');
  }
}
