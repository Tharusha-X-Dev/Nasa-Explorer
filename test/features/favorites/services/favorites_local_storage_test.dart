import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_1_0/features/favorites/models/favorite_model.dart';

void main() {
  group('Favorites local storage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('saves and loads favorite items using SharedPreferences', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final FavoriteModel favorite = FavoriteModel(
        title: 'Mars',
        description: 'Mars image',
        imageUrl: 'https://example.com/mars.jpg',
        nasaId: 'mars_1',
      );

      final List<String> encoded = <String>[json.encode(favorite.toJson())];
      await prefs.setStringList('favorites_items', encoded);

      final List<String> loadedRaw =
          prefs.getStringList('favorites_items') ?? <String>[];
      final List<FavoriteModel> loaded = loadedRaw
          .map(
            (String item) => FavoriteModel.fromJson(
              json.decode(item) as Map<String, dynamic>,
            ),
          )
          .toList();

      expect(loaded, hasLength(1));
      expect(loaded.first.title, equals('Mars'));
      expect(loaded.first.nasaId, equals('mars_1'));
    });
  });
}
