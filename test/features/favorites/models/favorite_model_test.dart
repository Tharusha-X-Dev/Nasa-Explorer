import 'package:flutter_test/flutter_test.dart';
import 'package:version_1_0/features/favorites/models/favorite_model.dart';

void main() {
  group('FavoriteModel', () {
    group('fromJson and toJson', () {
      test('correctly parses complete favorite JSON', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Aurora Borealis',
          'description': 'Beautiful northern lights',
          'imageUrl': 'https://example.com/image.jpg',
          'mediaType': 'image',
          'mediaUrl': 'https://example.com/media',
          'date': '2024-01-15',
          'nasaId': 'aurora_123',
          'keywords': <String>['aurora', 'lights', 'nature'],
          'localImagePath': '/storage/image.jpg',
        };

        final FavoriteModel model = FavoriteModel.fromJson(json);

        expect(model.title, equals('Aurora Borealis'));
        expect(model.description, equals('Beautiful northern lights'));
        expect(model.imageUrl, equals('https://example.com/image.jpg'));
        expect(model.mediaType, equals('image'));
        expect(model.mediaUrl, equals('https://example.com/media'));
        expect(model.date, equals('2024-01-15'));
        expect(model.nasaId, equals('aurora_123'));
        expect(model.keywords, equals(<String>['aurora', 'lights', 'nature']));
        expect(model.localImagePath, equals('/storage/image.jpg'));
      });

      test('handles missing optional fields gracefully', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Test Image',
          'description': 'Test description',
          'imageUrl': 'https://example.com/image.jpg',
        };

        final FavoriteModel model = FavoriteModel.fromJson(json);

        expect(model.title, equals('Test Image'));
        expect(model.mediaType, equals('image')); // default value
        expect(model.mediaUrl, isNull);
        expect(model.date, isNull);
        expect(model.nasaId, isNull);
        expect(model.localImagePath, isNull);
      });

      test('converts to JSON correctly', () {
        final FavoriteModel model = FavoriteModel(
          title: 'Test Image',
          description: 'Test description',
          imageUrl: 'https://example.com/image.jpg',
          mediaType: 'image',
          mediaUrl: 'https://example.com/media',
          date: '2024-01-15',
          nasaId: 'test_123',
          keywords: <String>['test'],
          localImagePath: '/storage/image.jpg',
        );

        final Map<String, dynamic> json = model.toJson();

        expect(json['title'], equals('Test Image'));
        expect(json['description'], equals('Test description'));
        expect(json['imageUrl'], equals('https://example.com/image.jpg'));
        expect(json['mediaType'], equals('image'));
      });

      test('round-trip fromJson and toJson preserves data', () {
        final Map<String, dynamic> originalJson = <String, dynamic>{
          'title': 'Round Trip Test',
          'description': 'Testing serialization',
          'imageUrl': 'https://example.com/image.jpg',
          'mediaType': 'image',
          'keywords': <String>['test'],
        };

        final FavoriteModel model = FavoriteModel.fromJson(originalJson);
        final Map<String, dynamic> resultJson = model.toJson();

        expect(resultJson['title'], equals(originalJson['title']));
        expect(resultJson['description'], equals(originalJson['description']));
        expect(resultJson['imageUrl'], equals(originalJson['imageUrl']));
      });

      test('uses default values for missing fields', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Test',
          'description': 'Test',
          'imageUrl': 'https://example.com/image.jpg',
        };

        final FavoriteModel model = FavoriteModel.fromJson(json);

        expect(model.mediaType, equals('image')); // default
        expect(model.keywords, isEmpty); // default empty list
      });
    });

    group('constructor', () {
      test('creates instance with required fields', () {
        final FavoriteModel model = FavoriteModel(
          title: 'Test Title',
          description: 'Test Description',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(model.title, equals('Test Title'));
        expect(model.description, equals('Test Description'));
        expect(model.imageUrl, equals('https://example.com/image.jpg'));
        expect(model.mediaType, equals('image')); // default
      });

      test('allows optional fields', () {
        final FavoriteModel model = FavoriteModel(
          title: 'Test Title',
          description: 'Test Description',
          imageUrl: 'https://example.com/image.jpg',
          nasaId: 'test_123',
          keywords: <String>['test'],
          localImagePath: '/storage/image.jpg',
        );

        expect(model.nasaId, equals('test_123'));
        expect(model.keywords, equals(<String>['test']));
        expect(model.localImagePath, equals('/storage/image.jpg'));
      });

      test('handles null keywords list', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Test',
          'description': 'Test',
          'imageUrl': 'https://example.com/image.jpg',
          'keywords': null,
        };

        final FavoriteModel model = FavoriteModel.fromJson(json);

        expect(model.keywords, isEmpty);
      });
    });

    group('equality and hashing', () {
      test('two models with same data should be different instances', () {
        final FavoriteModel model1 = FavoriteModel(
          title: 'Same Title',
          description: 'Same Description',
          imageUrl: 'https://example.com/image.jpg',
        );

        final FavoriteModel model2 = FavoriteModel(
          title: 'Same Title',
          description: 'Same Description',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(identical(model1, model2), isFalse);
      });
    });
  });
}
