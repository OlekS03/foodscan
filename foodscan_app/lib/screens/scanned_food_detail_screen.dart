import 'package:flutter/material.dart';
import '../global_keys.dart';

class ScannedFoodDetailScreen extends StatelessWidget {
  final String foodName;
  final String? companyName;
  final String ingredients;
  final Map<String, dynamic> nutriments;
  final List<dynamic> allergenTags;
  final List<dynamic> traces;
  final List<String> matchedAllergens;
  final List<String> matchedAdditives;
  final String? imageUrl;

  const ScannedFoodDetailScreen({
    super.key,
    required this.foodName,
    this.companyName,
    required this.ingredients,
    required this.nutriments,
    required this.allergenTags,
    required this.traces,
    required this.matchedAllergens,
    required this.matchedAdditives,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAllergic = matchedAllergens.isNotEmpty;

    // Calculate additive level (0.0 to 1.0)
    final additiveLevel = _calculateAdditiveLevel();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios, size: 20),
                        Text('Back', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Scanned',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Product Image and Name Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Product Image Placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey),
                            ),
                            child: imageUrl != null
                              ? Image.network(imageUrl!, fit: BoxFit.cover)
                              : Stack(
                                  children: [
                                    const Center(
                                      child: Text(
                                        'Food Product Picture',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    // X marks in corners
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.black,
                                        transform: Matrix4.rotationZ(0.785398),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.black,
                                        transform: Matrix4.rotationZ(-0.785398),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.black,
                                        transform: Matrix4.rotationZ(-0.785398),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.black,
                                        transform: Matrix4.rotationZ(0.785398),
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (companyName != null)
                                  Text(
                                    companyName!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // Allergen Status Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            isAllergic ? 'ALLERGIC' : 'NOT ALLERGIC',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isAllergic ? Colors.red : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          if (!isAllergic)
                            const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 24,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // Additives Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Additives: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  matchedAdditives.isNotEmpty
                                    ? matchedAdditives.join(', ')
                                    : 'No additives detected',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getAdditiveDescription(additiveLevel),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: additiveLevel,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getAdditiveColor(additiveLevel),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Low', style: TextStyle(fontSize: 12)),
                              Text('Moderate', style: TextStyle(fontSize: 12)),
                              Text('High', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // Ingredients Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingredients:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._buildIngredientsList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // Macro Nutrients Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Macro Nutrients',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._buildMacroNutrientsList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                    // Individual Macro Nutrient Bars
                    ..._buildMacroNutrientBars(),

                    const SizedBox(height: 20),

                    // Add to Food List Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'ADD TO FOOD LIST?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      foodListKey.currentState?.addItemToFoodsList(
                                        foodName,
                                        ingredients,
                                        nutriments,
                                        allergenTags,
                                        traces,
                                        matchedAllergens.isNotEmpty || matchedAdditives.isNotEmpty,
                                      );
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: const Text(
                                      'YES',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: const Text(
                                      'NO',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerX(double? top, double? left, double rotation, {double? bottom, double? right}) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: 2,
        height: 20,
        color: Colors.black,
        transform: Matrix4.rotationZ(rotation),
      ),
    );
  }

  List<Widget> _buildIngredientsList() {
    if (ingredients.isEmpty || ingredients == 'No ingredients listed') {
      return [
        const Text('ingredient #1'),
        const Text('ingredient #2'),
      ];
    }

    final ingredientList = ingredients.split(',').map((e) => e.trim()).take(10).toList();
    return ingredientList.map((ingredient) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(ingredient),
      )
    ).toList();
  }

  double _calculateAdditiveLevel() {
    if (matchedAdditives.isEmpty) return 0.2; // Low
    if (matchedAdditives.length <= 2) return 0.4; // Low-moderate
    if (matchedAdditives.length <= 4) return 0.7; // Moderate-high
    return 1.0; // High
  }

  Color _getAdditiveColor(double level) {
    if (level <= 0.3) return Colors.green;
    if (level <= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getAdditiveDescription(double level) {
    if (level <= 0.3) return 'Low amount of additives';
    if (level <= 0.6) return 'Moderate amount of additives';
    return 'High amount of additives';
  }

  List<Widget> _buildMacroNutrientsList() {
    List<Widget> nutrientsList = [];

    // Common nutrient keys to look for in the API data
    Map<String, List<String>> nutrientKeys = {
      'Energy': ['energy-kcal_100g', 'energy_100g', 'energy-kcal', 'energy'],
      'Protein': ['proteins_100g', 'proteins'],
      'Fat': ['fat_100g', 'fat'],
      'Saturated Fat': ['saturated-fat_100g', 'saturated-fat'],
      'Carbohydrates': ['carbohydrates_100g', 'carbohydrates'],
      'Sugars': ['sugars_100g', 'sugars'],
      'Fiber': ['fiber_100g', 'fiber'],
      'Sodium': ['sodium_100g', 'sodium'],
      'Salt': ['salt_100g', 'salt'],
    };

    // Check each nutrient and add if available
    nutrientKeys.forEach((nutrientName, keys) {
      double? value = _getNutrientValue(keys);
      if (value != null) {
        String unit = _getNutrientUnit(nutrientName);
        nutrientsList.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('$nutrientName: ${value.toStringAsFixed(1)}$unit'),
          ),
        );
      }
    });

    // If no nutrients found, show placeholder
    if (nutrientsList.isEmpty) {
      return [
        const Text('Energy: 250 kcal'),
        const Text('Protein: 12.5g'),
        const Text('Fat: 8.2g'),
        const Text('Carbohydrates: 35.0g'),
        const Text('No additional nutrient data available'),
      ];
    }

    return nutrientsList;
  }

  String _getNutrientUnit(String nutrientName) {
    switch (nutrientName.toLowerCase()) {
      case 'energy':
        return ' kcal';
      case 'sodium':
      case 'salt':
        return ' mg';
      default:
        return 'g';
    }
  }

  List<Widget> _buildMacroNutrientBars() {
    return [
      _buildNutrientBar('Protein', 'proteins_100g', 'proteins'),
      _buildNutrientBar('Fats', 'fat_100g', 'fat'),
      _buildNutrientBar('Carbs', 'carbohydrates_100g', 'carbohydrates'),
    ];
  }

  Widget _buildNutrientBar(String name, String primaryKey, String fallbackKey) {
    // Try to get nutrient value with different possible keys
    double? value = _getNutrientValue([primaryKey, fallbackKey, '${fallbackKey}_100g']);

    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      child: value != null ?
        _buildNutrientWithBar(name, value) :
        _buildNutrientNotProvided(name),
    );
  }

  Widget _buildNutrientWithBar(String name, double value) {
    final level = _calculateNutrientLevel(name, value);
    final description = _getNutrientDescription(name, level);
    final color = _getNutrientColor(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: level,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low', style: TextStyle(fontSize: 12)),
            Text('Moderate', style: TextStyle(fontSize: 12)),
            Text('High', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientNotProvided(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Info not provided',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        // X mark for not provided
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              '✕',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Moderate', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('High', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  double? _getNutrientValue(List<String> possibleKeys) {
    for (String key in possibleKeys) {
      final value = nutriments[key];
      if (value != null) {
        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          return double.tryParse(value);
        }
      }
    }
    return null;
  }

  double _calculateNutrientLevel(String nutrientName, double value) {
    // Handle zero values - should show no bar at all
    if (value <= 0) return 0.0;

    // Define thresholds for different nutrients (per 100g)
    Map<String, Map<String, double>> thresholds = {
      'Protein': {'low': 5.0, 'high': 20.0},
      'Fats': {'low': 3.0, 'high': 17.5},
      'Carbs': {'low': 5.0, 'high': 22.5},
    };

    final threshold = thresholds[nutrientName];
    if (threshold == null) return 0.5; // Default to moderate if unknown

    if (value <= threshold['low']!) {
      return 0.25; // Low
    } else if (value >= threshold['high']!) {
      return 1.0; // High
    } else {
      // Calculate position between low and high
      final range = threshold['high']! - threshold['low']!;
      final position = (value - threshold['low']!) / range;
      return 0.25 + (position * 0.75); // Scale between 0.25 and 1.0
    }
  }

  String _getNutrientDescription(String nutrientName, double level) {
    if (level <= 0.33) {
      return 'Low amount of ${nutrientName.toLowerCase()}';
    } else if (level <= 0.66) {
      return 'Moderate amount of ${nutrientName.toLowerCase()}';
    } else {
      return 'Great amount of ${nutrientName.toLowerCase()}';
    }
  }

  Color _getNutrientColor(double level) {
    if (level <= 0.33) return Colors.green;
    if (level <= 0.66) return Colors.orange;
    return Colors.red;
  }
}
