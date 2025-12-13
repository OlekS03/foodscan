import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foodscan_app/services/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserPreferences', () {
    setUp(() {
      // Reset mock storage before every test
      SharedPreferences.setMockInitialValues({});
    });

    test('getAllergens returns empty when none set', () async {
      final allergens = await UserPreferences.getAllergens();
      expect(allergens, []);
    });

    test('setAllergens stores allergens', () async {
      await UserPreferences.setAllergens(['milk', 'peanuts']);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getStringList('user_allergens'), ['milk', 'peanuts']);
    });

    test('getAdditives returns empty when none set', () async {
      final additives = await UserPreferences.getAdditives();
      expect(additives, []);
    });

    test('setAdditives stores additives', () async {
      await UserPreferences.setAdditives(['e100', 'e200']);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getStringList('user_additives'), ['e100', 'e200']);
    });

    // ---------- hasAllergens tests ----------
    test('hasAllergens returns false when user allergens list is empty', () async {
      final result = await UserPreferences.hasAllergens(
        'Contains milk and sugar',
        ['milk_tag'],
        ['milk_trace'],
      );

      expect(result, false);
    });

    test('hasAllergens detects allergens inside ingredients', () async {
      await UserPreferences.setAllergens(['milk']);

      final result = await UserPreferences.hasAllergens(
        'This product contains Milk extract',
        [],
        [],
      );

      expect(result, true);
    });

    test('hasAllergens detects allergens in allergenTags', () async {
      await UserPreferences.setAllergens(['peanut']);

      final result = await UserPreferences.hasAllergens(
        'no peanuts here',
        ['contains_peanut_oil'],
        [],
      );

      expect(result, true);
    });

    test('hasAllergens detects allergens in traces', () async {
      await UserPreferences.setAllergens(['gluten']);

      final result = await UserPreferences.hasAllergens(
        'ingredients',
        [],
        ['may contain traces of GLUTEN'],
      );

      expect(result, true);
    });

    test('hasAllergens returns false if none found', () async {
      await UserPreferences.setAllergens(['egg']);

      final result = await UserPreferences.hasAllergens(
        'contains sugar and salt',
        ['milk_tag'],
        ['soy_trace'],
      );

      expect(result, false);
    });

    // ---------- findMatchingAllergens tests ----------
    test('findMatchingAllergens returns matching items', () async {
      await UserPreferences.setAllergens(['milk', 'soy', 'egg']);

      final matches = await UserPreferences.findMatchingAllergens(
        'Contains MILK and sugar',
        ['soy_is_present'],
        [],
      );

      expect(matches, ['milk', 'soy']);
    });

    // ---------- hasAdditives tests ----------
    test('hasAdditives detects additive inside ingredients', () async {
      await UserPreferences.setAdditives(['e100']);

      final result = await UserPreferences.hasAdditives('Contains E100 and sugar');

      expect(result, true);
    });

    // ---------- findMatchingAdditives tests ----------
    test('findMatchingAdditives returns matching additives', () async {
      await UserPreferences.setAdditives(['e100', 'e200']);

      final matches = await UserPreferences.findMatchingAdditives(
        'Contains E200 and colorants',
      );

      expect(matches, ['e200']);
    });
  });
}