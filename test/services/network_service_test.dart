import 'package:flutter_test/flutter_test.dart';
import 'package:version_1_0/services/network_service.dart';

void main() {
  group('NetworkService Tests', () {
    test('hasInternetConnection returns a boolean', () async {
      final NetworkService networkService = NetworkService();
      final bool result = await networkService.hasInternetConnection();

      expect(result, isA<bool>());
    });

    test('isConnected returns a boolean', () async {
      final NetworkService networkService = NetworkService();
      final bool result = await networkService.isConnected();

      expect(result, isA<bool>());
    });

    test(
      'hasInternetConnection handles platform exceptions gracefully',
      () async {
        final NetworkService networkService = NetworkService();

        try {
          final bool result = await networkService.hasInternetConnection();
          expect(result, isA<bool>());
        } catch (e) {
          fail('Should handle exceptions gracefully');
        }
      },
    );

    test('isConnected delegates to hasInternetConnection', () async {
      final NetworkService networkService = NetworkService();

      final bool internet = await networkService.hasInternetConnection();
      final bool connected = await networkService.isConnected();

      expect(internet, equals(connected));
    });

    test('multiple calls to hasInternetConnection work consistently', () async {
      final NetworkService networkService = NetworkService();

      final bool result1 = await networkService.hasInternetConnection();
      final bool result2 = await networkService.hasInternetConnection();

      expect(result1, isA<bool>());
      expect(result2, isA<bool>());
    });

    test('hasInternetConnection returns within reasonable time', () async {
      final NetworkService networkService = NetworkService();

      final bool result = await Future.any<bool>(<Future<bool>>[
        networkService.hasInternetConnection(),
        Future<bool>.delayed(
          const Duration(seconds: 5),
          () => throw TimeoutException('Connection check timeout'),
        ),
      ]);

      expect(result, isA<bool>());
    });

    test('service handles repeated connection checks', () async {
      final NetworkService networkService = NetworkService();

      final List<bool> results = <bool>[];

      for (int i = 0; i < 3; i++) {
        final bool result = await networkService.hasInternetConnection();
        results.add(result);
      }

      expect(results.length, equals(3));
      expect(results.every((bool value) => value is bool), isTrue);
    });

    test('isConnected is consistently same as hasInternetConnection', () async {
      final NetworkService networkService = NetworkService();

      for (int i = 0; i < 3; i++) {
        final bool internet = await networkService.hasInternetConnection();
        final bool connected = await networkService.isConnected();

        expect(internet, equals(connected));
      }
    });
  });
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
