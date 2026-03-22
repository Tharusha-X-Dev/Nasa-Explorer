import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites_items';
  static const String _imagesDir = 'nasa_favorites_images';

  Future<List<FavoriteModel>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_favoritesKey) ?? <String>[];

    return saved
        .map(
          (String item) =>
              FavoriteModel.fromJson(json.decode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> addFavorite(FavoriteModel item) async {
    final List<FavoriteModel> currentItems = await getFavorites();

    final bool alreadyExists = currentItems.any(
      (FavoriteModel existing) => _isSameItem(existing, item),
    );

    if (!alreadyExists) {
      // Download and save the image locally
      final String? localPath = await _downloadAndSaveImage(item.imageUrl);

      // Create a new FavoriteModel with the local image path
      final FavoriteModel itemWithLocalPath = FavoriteModel(
        title: item.title,
        description: item.description,
        imageUrl: item.imageUrl,
        mediaType: item.mediaType,
        mediaUrl: item.mediaUrl,
        date: item.date,
        nasaId: item.nasaId,
        keywords: item.keywords,
        localImagePath: localPath,
      );

      currentItems.insert(0, itemWithLocalPath);
      await _saveFavorites(currentItems);
    }
  }

  Future<void> removeFavorite(FavoriteModel item) async {
    final List<FavoriteModel> currentItems = await getFavorites();

    currentItems.removeWhere(
      (FavoriteModel existing) => _isSameItem(existing, item),
    );

    // Delete the local image file if it exists
    if (item.localImagePath != null) {
      try {
        final File imageFile = File(item.localImagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (_) {
        // Silently fail if deletion fails
      }
    }

    await _saveFavorites(currentItems);
  }

  Future<bool> containsFavorite(FavoriteModel item) async {
    final List<FavoriteModel> currentItems = await getFavorites();
    return currentItems.any(
      (FavoriteModel existing) => _isSameItem(existing, item),
    );
  }

  Future<String?> _downloadAndSaveImage(String imageUrl) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create the images subdirectory if it doesn't exist
      final Directory imagesDirectory = Directory('${appDir.path}/$_imagesDir');
      if (!await imagesDirectory.exists()) {
        await imagesDirectory.create(recursive: true);
      }

      // Generate a unique filename based on the URL
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageUrl.hashCode.abs()}.jpg';
      final String filePath = '${imagesDirectory.path}/$fileName';

      // Download the image
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Save the image to the local file
        final File imageFile = File(filePath);
        await imageFile.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (_) {
      // Silently fail and return null if download fails
    }

    return null;
  }

  bool _isSameItem(FavoriteModel first, FavoriteModel second) {
    if (first.nasaId != null && second.nasaId != null) {
      return first.nasaId == second.nasaId;
    }

    return first.title == second.title && first.imageUrl == second.imageUrl;
  }

  Future<void> _saveFavorites(List<FavoriteModel> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> encoded = items
        .map((FavoriteModel item) => json.encode(item.toJson()))
        .toList();

    await prefs.setStringList(_favoritesKey, encoded);
  }
}
