import 'package:flutter_test/flutter_test.dart';
import 'package:version_1_0/models/user_profile_model.dart';

void main() {
  group('UserProfileModel', () {
    group('fromMap and toMap', () {
      test('correctly creates model from map', () {
        final Map<String, dynamic> map = <String, dynamic>{
          'firstName': 'John',
          'lastName': 'Doe',
          'gender': 'male',
          'email': 'john@example.com',
        };

        final UserProfileModel model = UserProfileModel.fromMap(map);

        expect(model.firstName, equals('John'));
        expect(model.lastName, equals('Doe'));
        expect(model.gender, equals('male'));
        expect(model.email, equals('john@example.com'));
      });

      test('converts model to map correctly', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'Jane',
          lastName: 'Smith',
          gender: 'female',
          email: 'jane@example.com',
        );

        final Map<String, dynamic> map = model.toMap();

        expect(map['firstName'], equals('Jane'));
        expect(map['lastName'], equals('Smith'));
        expect(map['gender'], equals('female'));
        expect(map['email'], equals('jane@example.com'));
      });

      test('round-trip fromMap and toMap preserves data', () {
        final Map<String, dynamic> originalMap = <String, dynamic>{
          'firstName': 'Test',
          'lastName': 'User',
          'gender': 'other',
          'email': 'test@example.com',
        };

        final UserProfileModel model = UserProfileModel.fromMap(originalMap);
        final Map<String, dynamic> resultMap = model.toMap();

        expect(resultMap['firstName'], equals(originalMap['firstName']));
        expect(resultMap['lastName'], equals(originalMap['lastName']));
        expect(resultMap['gender'], equals(originalMap['gender']));
        expect(resultMap['email'], equals(originalMap['email']));
      });

      test('handles missing fields with defaults', () {
        final Map<String, dynamic> map = <String, dynamic>{};

        final UserProfileModel model = UserProfileModel.fromMap(map);

        expect(model.firstName, equals(''));
        expect(model.lastName, equals(''));
        expect(model.gender, equals('male')); // default
        expect(model.email, equals(''));
      });

      test('handles null values by converting to empty string', () {
        final Map<String, dynamic> map = <String, dynamic>{
          'firstName': null,
          'lastName': null,
          'gender': null,
          'email': null,
        };

        final UserProfileModel model = UserProfileModel.fromMap(map);

        expect(model.firstName, equals(''));
        expect(model.lastName, equals(''));
        expect(model.email, equals(''));
      });

      test('handles numeric values by converting to string', () {
        final Map<String, dynamic> map = <String, dynamic>{
          'firstName': 123,
          'lastName': 456,
          'gender': 789,
          'email': 'test@example.com',
        };

        final UserProfileModel model = UserProfileModel.fromMap(map);

        expect(model.firstName, equals('123'));
        expect(model.lastName, equals('456'));
        expect(model.gender, equals('789'));
      });
    });

    group('displayName getter', () {
      test('returns full name when both first and last names exist', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'John',
          lastName: 'Doe',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('John Doe'));
      });

      test('returns only first name when last name is empty', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'John',
          lastName: '',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('John'));
      });

      test('returns only last name when first name is empty', () {
        final UserProfileModel model = UserProfileModel(
          firstName: '',
          lastName: 'Doe',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('Doe'));
      });

      test('returns "User" when both names are empty', () {
        final UserProfileModel model = UserProfileModel(
          firstName: '',
          lastName: '',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('User'));
      });

      test('trims whitespace from names', () {
        final UserProfileModel model = UserProfileModel(
          firstName: '  John  ',
          lastName: '  Doe  ',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('John Doe'));
      });

      test('handles names with only whitespace', () {
        final UserProfileModel model = UserProfileModel(
          firstName: '   ',
          lastName: '   ',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('User'));
      });

      test('handles multiple spaces between names', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'John',
          lastName: 'Doe',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.displayName, equals('John Doe'));
        expect(model.displayName.contains('  '), isFalse); // No double spaces
      });
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'Test',
          lastName: 'User',
          gender: 'male',
          email: 'test@example.com',
        );

        expect(model.firstName, equals('Test'));
        expect(model.lastName, equals('User'));
        expect(model.gender, equals('male'));
        expect(model.email, equals('test@example.com'));
      });

      test('preserves leading/trailing whitespace in constructor', () {
        final UserProfileModel model = UserProfileModel(
          firstName: '  John  ',
          lastName: '  Doe  ',
          gender: 'male',
          email: 'john@example.com',
        );

        expect(model.firstName, equals('  John  '));
        expect(model.lastName, equals('  Doe  '));
      });
    });

    group('gender values', () {
      test('accepts various gender values', () {
        final List<String> genders = <String>['male', 'female', 'other', 'prefer not to say'];

        for (final String gender in genders) {
          final UserProfileModel model = UserProfileModel(
            firstName: 'Test',
            lastName: 'User',
            gender: gender,
            email: 'test@example.com',
          );

          expect(model.gender, equals(gender));
        }
      });
    });

    group('email validation', () {
      test('stores email value as-is without validation', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'Test',
          lastName: 'User',
          gender: 'male',
          email: 'invalid-email',
        );

        expect(model.email, equals('invalid-email'));
      });

      test('allows empty email', () {
        final UserProfileModel model = UserProfileModel(
          firstName: 'Test',
          lastName: 'User',
          gender: 'male',
          email: '',
        );

        expect(model.email, equals(''));
      });
    });
  });
}
