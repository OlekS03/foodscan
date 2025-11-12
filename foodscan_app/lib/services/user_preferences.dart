import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _allergensKey = 'user_allergens';
  static const String _additivesKey = 'user_additives';

  static Future<List<String>> getAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_allergensKey) ?? [];
  }

  static Future<List<String>> getAdditives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_additivesKey) ?? [];
  }

  static Future<bool> hasAllergens(String ingredients, List<dynamic> allergenTags, List<dynamic> traces) async {
    final userAllergens = await getAllergens();
    if (userAllergens.isEmpty) return false;

    final lowerIngredients = ingredients.toLowerCase();
    final lowerAllergenTags = allergenTags.map((e) => e.toString().toLowerCase()).toList();
    final lowerTraces = traces.map((e) => e.toString().toLowerCase()).toList();
    final lowerUserAllergens = userAllergens.map((e) => e.toLowerCase()).toList();

    for (final allergen in lowerUserAllergens) {
      if (lowerIngredients.contains(allergen)) {
        return true;
      }
    }

    for (final allergen in lowerUserAllergens) {
      if (lowerAllergenTags.any((tag) => tag.contains(allergen))) {
        return true;
      }
    }

    for (final allergen in lowerUserAllergens) {
      if (lowerTraces.any((trace) => trace.contains(allergen))) {
        return true;
      }
    }

    return false;
  }

  static Future<bool> hasAdditives(String ingredients) async {
    final userAdditives = await getAdditives();
    if (userAdditives.isEmpty) return false;

    final lowerIngredients = ingredients.toLowerCase();
    final lowerUserAdditives = userAdditives.map((e) => e.toLowerCase()).toList();

    for (final additive in lowerUserAdditives) {
      if (lowerIngredients.contains(additive)) {
        return true;
      }
    }

    return false;
  }

  static Future<List<String>> findMatchingAllergens(String ingredients, List<dynamic> allergenTags, List<dynamic> traces) async {
    final userAllergens = await getAllergens();
    if (userAllergens.isEmpty) return [];

    final matches = <String>[];
    final lowerIngredients = ingredients.toLowerCase();
    final lowerAllergenTags = allergenTags.map((e) => e.toString().toLowerCase()).toList();
    final lowerTraces = traces.map((e) => e.toString().toLowerCase()).toList();

    for (final allergen in userAllergens) {
      final lowerAllergen = allergen.toLowerCase();
      if (lowerIngredients.contains(lowerAllergen) ||
          lowerAllergenTags.any((tag) => tag.contains(lowerAllergen)) ||
          lowerTraces.any((trace) => trace.contains(lowerAllergen))) {
        matches.add(allergen);
      }
    }

    return matches;
  }

  static Future<List<String>> findMatchingAdditives(String ingredients) async {
    final userAdditives = await getAdditives();
    if (userAdditives.isEmpty) return [];

    final matches = <String>[];
    final lowerIngredients = ingredients.toLowerCase();

    for (final additive in userAdditives) {
      if (lowerIngredients.contains(additive.toLowerCase())) {
        matches.add(additive);
      }
    }

    return matches;
  }

  static Future<void> setAllergens(List<String> allergens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_allergensKey, allergens);
  }

  static Future<void> setAdditives(List<String> additives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_additivesKey, additives);
  }
}
