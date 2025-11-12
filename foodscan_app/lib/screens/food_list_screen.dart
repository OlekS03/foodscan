import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => FoodListScreenState();
}

class FoodListScreenState extends State<FoodListScreen> with SingleTickerProviderStateMixin {
  List<Map<String, Object>> foodInfo = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadFoods();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedFoods = prefs.getStringList('foods_list');

    if (savedFoods == null || savedFoods.isEmpty) {
      if (mounted) {
        setState(() {
          foodInfo = [];
        });
      }
      return;
    }

    try {
      final loadedFoods = savedFoods.map((item) {
        final parts = item.split('|');
        if (parts.isEmpty) return null;

        return {
          'foodName': parts[0],
          'ingredients': parts.length > 1 ? parts[1] : '',
          'nutriments': parts.length > 2 ? _parseNutriments(parts[2]) : <String, Object>{},
          'allergenTags': parts.length > 3 ?
            (parts[3].isEmpty ? <Object>[] : parts[3].split(',').map((e) => e as Object).toList()) : <Object>[],
          'traces': parts.length > 4 ?
            (parts[4].isEmpty ? <Object>[] : parts[4].split(',').map((e) => e as Object).toList()) : <Object>[],
          'hasAllergen': parts.length > 5 ? parts[5].toLowerCase() == 'true' : false,
          'expanded': false,
        };
      })
      .where((item) => item != null)
      .map((item) => Map<String, Object>.from(item!))
      .toList();

      if (mounted) {
        setState(() {
          foodInfo = loadedFoods;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          foodInfo = [];
        });
      }
    }
  }

  Map<String, Object> _parseNutriments(String nutrimentsStr) {
    try {
      // Parse the JSON string back into a Map
      final Map<String, dynamic> decoded = jsonDecode(nutrimentsStr);
      return Map<String, Object>.from(decoded);
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedFoods = foodInfo.map((food) {
        final nutriments = food['nutriments'] as Map<String, Object>;

        // Convert nutriments map directly to JSON string
        final nutrimentStr = jsonEncode(nutriments);

        // Convert lists to string format
        final allergenTags = (food['allergenTags'] as List).join(',');
        final traces = (food['traces'] as List).join(',');

        return [
          food['foodName'].toString(),
          food['ingredients'].toString(),
          nutrimentStr,
          allergenTags,
          traces,
          food['hasAllergen'].toString(),
        ].join('|');
      }).toList();

      await prefs.setStringList('foods_list', encodedFoods);
    } catch (e) {
      print('Error saving foods: $e');
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      foodInfo[index]['expanded'] = !(foodInfo[index]['expanded'] as bool);
    });
  }

  void _removeFood(int index) {
    setState(() {
      foodInfo.removeAt(index);
      _saveFoods();
    });
  }

  void addItemToFoodsList(
    String foodName,
    String ingredients,
    Map<String, dynamic> nutriments,
    List<dynamic> allergenTags,
    List<dynamic> traces,
    bool hasAllergen,
  ) {
    // Ensure nutriments are properly formatted
    final formattedNutriments = Map<String, Object>.from({
      'energy-kcal': nutriments['energy-kcal'] ?? 0,
      'proteins': nutriments['proteins'] ?? 0,
      'carbohydrates': nutriments['carbohydrates'] ?? 0,
      'fat': nutriments['fat'] ?? 0,
    });

    setState(() {
      foodInfo.add({
        'foodName': foodName as Object,
        'ingredients': ingredients as Object,
        'nutriments': formattedNutriments,
        'allergenTags': allergenTags.map((e) => e as Object).toList(),
        'traces': traces.map((e) => e as Object).toList(),
        'hasAllergen': hasAllergen as Object,
        'expanded': false as Object,
      });
    });
    _saveFoods();
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Food List is Currently Empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a food product and add it\nto see it here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, Object> food, int index) {
    final bool isExpanded = food['expanded'] as bool;
    final bool hasAllergen = food['hasAllergen'] as bool;
    final String foodName = food['foodName'] as String;
    final String ingredients = food['ingredients'] as String;
    final List<dynamic> allergenTags = food['allergenTags'] as List<dynamic>;
    final Map<String, Object> nutriments = food['nutriments'] as Map<String, Object>;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final cardColor = hasAllergen
        ? (isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red[100])
        : theme.cardColor;

    final textColor = hasAllergen
        ? (isDarkMode ? Colors.red[200] : Colors.red[900])
        : theme.textTheme.bodyLarge?.color;
    final companyColor = hasAllergen
        ? (isDarkMode ? Colors.red[200] : Colors.red[700])
        : theme.textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Food item header
          InkWell(
            onTap: () => _toggleExpand(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Placeholder for food image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Company Name',
                          style: TextStyle(
                            color: companyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeFood(index),
                    color: textColor,
                  ),
                  IconButton(
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () => _toggleExpand(index),
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: hasAllergen
                    ? (isDarkMode ? Colors.red.withOpacity(0.3) : Colors.red[100])
                    : (isDarkMode ? Colors.green.withOpacity(0.3) : Colors.green[100]),
              ),
              child: Row(
                children: [
                  if (hasAllergen) ...[
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'ALLERGIC',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'NOT ALLERGIC',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildNutritionInfo(nutriments),
            _buildAdditiveSection(),
            _buildInfoSection('Ingredients:', ingredients),
            if (allergenTags.isNotEmpty)
              _buildInfoSection('Allergens:', allergenTags.join(', ')),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditiveSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additives (WIP)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('Low amount of additives (WIP)'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Low'),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green[300]!,
                        Colors.yellow[300]!,
                        Colors.red[300]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text('High'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(Map<String, Object> nutriments) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[400],
        border: Border(
          bottom: BorderSide(color: (isDarkMode ? Colors.grey[700] : Colors.grey[500])!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientBox('Calories',
                nutriments['energy-kcal']?.toString() ?? '0',
                'kcal'),
              _buildNutrientBox('Protein',
                nutriments['proteins']?.toString() ?? '0',
                'g'),
              _buildNutrientBox('Carbs',
                nutriments['carbohydrates']?.toString() ?? '0',
                'g'),
              _buildNutrientBox('Fat',
                nutriments['fat']?.toString() ?? '0',
                'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBox(String label, String value, String unit) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food List'),
      ),
      body: foodInfo.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: foodInfo.length,
            itemBuilder: (context, index) => _buildFoodItem(foodInfo[index], index),
          ),
    );
  }
}
