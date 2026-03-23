import 'package:flutter_test/flutter_test.dart';
import 'package:version_1_0/features/explore/models/nasa_image_model.dart';

void main() {
  group('NasaImageModel', () {
    group('fromJson', () {
      test('correctly parses complete NASA image JSON', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'title': 'Hubble Deep Field',
              'description': 'Historic deep field observation',
              'date_created': '1995-12-26',
              'nasa_id': 'hubble_deep_field',
              'center': 'STScI',
              'photographer': 'Robert Williams',
              'keywords': <dynamic>['astronomy', 'space', 'hubble'],
              'media_type': 'image',
            }
          ],
          'links': <dynamic>[
            <String, dynamic>{
              'render': 'image',
              'href': 'https://example.com/image.jpg',
            }
          ],
          'href': 'https://example.com/collection',
        };

        final NasaImageModel model = NasaImageModel.fromJson(json);

        expect(model.title, equals('Hubble Deep Field'));
        expect(model.description, equals('Historic deep field observation'));
        expect(model.dateCreated, equals('1995-12-26'));
        expect(model.nasaId, equals('hubble_deep_field'));
        expect(model.center, equals('STScI'));
        expect(model.photographer, equals('Robert Williams'));
        expect(model.keywords, equals(<String>['astronomy', 'space', 'hubble']));
        expect(model.mediaType, equals('image'));
        expect(model.imageUrl, equals('https://example.com/image.jpg'));
      });

      test('handles missing data array gracefully', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'links': <dynamic>[],
        };

        final NasaImageModel model = NasaImageModel.fromJson(json);

        expect(model.title, equals('NASA Image'));
        expect(model.description, equals(''));
      });

      test('handles empty keywords list', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'title': 'Image Title',
              'keywords': <dynamic>[],
            }
          ],
          'links': <dynamic>[],
        };

        final NasaImageModel model = NasaImageModel.fromJson(json);

        expect(model.keywords, isEmpty);
      });

      test('correctly extracts image URL from links', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'title': 'Test Image',
            }
          ],
          'links': <dynamic>[
            <String, dynamic>{
              'render': 'other',
              'href': 'https://example.com/other.jpg',
            },
            <String, dynamic>{
              'render': 'image',
              'href': 'https://example.com/image.jpg',
            }
          ],
        };

        final NasaImageModel model = NasaImageModel.fromJson(json);

        expect(model.imageUrl, equals('https://example.com/image.jpg'));
        expect(model.thumbnailUrl, equals('https://example.com/other.jpg'));
      });

      test('handles null and empty URLs without crashing', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'title': 'Test Image',
            }
          ],
          'links': <dynamic>[
            <String, dynamic>{
              'render': 'image',
              'href': null,
            },
            <String, dynamic>{
              'render': 'image',
              'href': '',
            }
          ],
        };

        final NasaImageModel model = NasaImageModel.fromJson(json);

        expect(model.title, equals('Test Image'));
      });

      test('converts keywords to string list', () {
        final Map<String, dynamic> json = <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'title': 'Test',
              'keywords': <dynamic>[123, 'text', true],
            }
          ],
          'links': <dynamic>[],
        };

        final NasaImageModel model = NasaImageModel.fromJson(json);

        expect(model.keywords, isNotEmpty);
      });
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        final NasaImageModel model = NasaImageModel(
          title: 'Test Title',
          description: 'Test Description',
          dateCreated: '2024-01-15',
          nasaId: 'test_id',
          center: 'Test Center',
          photographer: 'Test Photographer',
          keywords: <String>['test', 'image'],
          mediaType: 'image',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(model.title, equals('Test Title'));
        expect(model.nasaId, equals('test_id'));
        expect(model.imageUrl, equals('https://example.com/image.jpg'));
      });

      test('allows null optional fields', () {
        final NasaImageModel model = NasaImageModel(
          title: 'Test Title',
          description: 'Test Description',
          dateCreated: '2024-01-15',
          nasaId: 'test_id',
          center: 'Test Center',
          photographer: 'Test Photographer',
          keywords: <String>[],
          mediaType: 'image',
          imageUrl: 'https://example.com/image.jpg',
          thumbnailUrl: null,
          mediaUrl: null,
        );

        expect(model.thumbnailUrl, isNull);
        expect(model.mediaUrl, isNull);
      });
    });
  });
}
