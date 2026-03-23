import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_1_0/features/settings/services/settings_service.dart';

void main() {
  group('SettingsService Local Storage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('getDarkMode returns false by default', () async {
      final SettingsService settingsService = SettingsService();
      final bool isDarkMode = await settingsService.getDarkMode();

      expect(isDarkMode, isFalse);
    });

    test('setDarkMode saves true value', () async {
      final SettingsService settingsService = SettingsService();
      
      await settingsService.setDarkMode(true);
      final bool isDarkMode = await settingsService.getDarkMode();

      expect(isDarkMode, isTrue);
    });

    test('setDarkMode saves false value', () async {
      final SettingsService settingsService = SettingsService();
      
      await settingsService.setDarkMode(false);
      final bool isDarkMode = await settingsService.getDarkMode();

      expect(isDarkMode, isFalse);
    });

    test('getDarkMode returns previously set value', () async {
      final SettingsService settingsService1 = SettingsService();
      
      await settingsService1.setDarkMode(true);
      
      // Create new instance to verify persistence
      final SettingsService settingsService2 = SettingsService();
      final bool isDarkMode = await settingsService2.getDarkMode();

      expect(isDarkMode, isTrue);
    });

    test('can toggle dark mode multiple times', () async {
      final SettingsService settingsService = SettingsService();
      
      await settingsService.setDarkMode(true);
      expect(await settingsService.getDarkMode(), isTrue);
      
      await settingsService.setDarkMode(false);
      expect(await settingsService.getDarkMode(), isFalse);
      
      await settingsService.setDarkMode(true);
      expect(await settingsService.getDarkMode(), isTrue);
    });

    test('handles concurrent dark mode checks', () async {
      final SettingsService settingsService = SettingsService();
      
      await settingsService.setDarkMode(true);
      
      final List<Future<bool>> futures = <Future<bool>>[
        settingsService.getDarkMode(),
        settingsService.getDarkMode(),
        settingsService.getDarkMode(),
      ];
      
      final List<bool> results = await Future.wait(futures);
      
      expect(results, equals(<bool>[true, true, true]));
    });

    test('handles rapid mode changes', () async {
      final SettingsService settingsService = SettingsService();
      
      for (int i = 0; i < 5; i++) {
        await settingsService.setDarkMode(i.isEven);
        final bool isDarkMode = await settingsService.getDarkMode();
        expect(isDarkMode, equals(i.isEven));
      }
    });

    test('getDarkMode works without prior initialization', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      
      final SettingsService settingsService = SettingsService();
      final bool isDarkMode = await settingsService.getDarkMode();

      expect(isDarkMode, isFalse);
    });

    test('settings persist across service instances', () async {
      final SettingsService service1 = SettingsService();
      await service1.setDarkMode(true);

      final SettingsService service2 = SettingsService();
      final bool isDarkMode = await service2.getDarkMode();

      expect(isDarkMode, isTrue);
    });
  });
}
