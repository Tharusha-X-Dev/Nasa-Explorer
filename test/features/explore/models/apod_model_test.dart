import 'package:flutter_test/flutter_test.dart';
import 'package:version_1_0/features/explore/models/apod_model.dart';

void main() {
  group('ApodModel', () {
    group('fromJson', () {
      test('correctly parses complete JSON', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Aurora Borealis',
          'explanation': 'The northern lights...',
          'date': '2024-01-15',
          'url': 'https://example.com/image.jpg',
          'hdurl': 'https://example.com/image_hd.jpg',
          'media_type': 'image',
          'copyright': 'John Doe',
          'thumbnail_url': 'https://example.com/thumb.jpg',
        };

        final ApodModel model = ApodModel.fromJson(json);

        expect(model.title, equals('Aurora Borealis'));
        expect(model.explanation, equals('The northern lights...'));
        expect(model.date, equals('2024-01-15'));
        expect(model.url, equals('https://example.com/image.jpg'));
        expect(model.hdUrl, equals('https://example.com/image_hd.jpg'));
        expect(model.mediaType, equals('image'));
        expect(model.copyright, equals('John Doe'));
        expect(model.thumbnailUrl, equals('https://example.com/thumb.jpg'));
      });

      test('handles missing optional fields gracefully', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Test Image',
          'explanation': 'Test explanation',
          'date': '2024-01-15',
          'url': 'https://example.com/image.jpg',
          'media_type': 'image',
        };

        final ApodModel model = ApodModel.fromJson(json);

        expect(model.title, equals('Test Image'));
        expect(model.hdUrl, isNull);
        expect(model.copyright, isNull);
        expect(model.thumbnailUrl, isNull);
      });

      test('uses empty string for missing required fields', () {
        final Map<String, dynamic> json = <String, dynamic>{};

        final ApodModel model = ApodModel.fromJson(json);

        expect(model.title, equals(''));
        expect(model.explanation, equals(''));
        expect(model.date, equals(''));
        expect(model.url, equals(''));
        expect(model.mediaType, equals(''));
      });

      test('correctly parses video media type', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': 'Space Station Video',
          'explanation': 'A video of the ISS',
          'date': '2024-01-15',
          'url': 'https://example.com/video.mp4',
          'media_type': 'video',
        };

        final ApodModel model = ApodModel.fromJson(json);

        expect(model.mediaType, equals('video'));
        expect(model.url, equals('https://example.com/video.mp4'));
      });

      test('handles null values in JSON without crashing', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'title': null,
          'explanation': null,
          'date': null,
          'url': null,
          'media_type': null,
          'hdurl': null,
          'copyright': null,
        };

        final ApodModel model = ApodModel.fromJson(json);

        expect(model.title, equals(''));
        expect(model.explanation, equals(''));
      });
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        final ApodModel model = ApodModel(
          title: 'Test Title',
          explanation: 'Test Explanation',
          date: '2024-01-15',
          url: 'https://example.com/image.jpg',
          mediaType: 'image',
        );

        expect(model.title, equals('Test Title'));
        expect(model.explanation, equals('Test Explanation'));
        expect(model.date, equals('2024-01-15'));
        expect(model.url, equals('https://example.com/image.jpg'));
        expect(model.mediaType, equals('image'));
      });

      test('allows null optional fields', () {
        final ApodModel model = ApodModel(
          title: 'Test Title',
          explanation: 'Test Explanation',
          date: '2024-01-15',
          url: 'https://example.com/image.jpg',
          mediaType: 'image',
          hdUrl: null,
          copyright: null,
        );

        expect(model.hdUrl, isNull);
        expect(model.copyright, isNull);
      });
    });
  });
}
