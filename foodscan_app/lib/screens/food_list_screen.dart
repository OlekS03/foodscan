import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_preferences.dart';
import 'dart:convert';
import 'scanned_food_detail_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => FoodListScreenState();
}

class FoodListScreenState extends State<FoodListScreen> with SingleTickerProviderStateMixin {
  List<Map<String, Object>> foodInfo = [];
  late AnimationController _controller;
  List<String> matchedAllergens = [];
  List<String> matchedAdditives = [];
  Map<String, dynamic> nutriments = {};
  
  Future<void> reloadFoods() async {
    await _loadFoods();
  }

  bool _isFilterOpen = false;

  String? _selectedSort;
  bool _filterAllergens = false;
  bool _filterAdditives = false;
  bool _filterSafe = false;

  List<Map<String, Object>> _getFilteredSortedFoods() {
    List<Map<String, Object>> filtered = List.from(foodInfo);

    filtered = filtered.where((food) {
      final hasAllergen = food['hasAllergen'] as bool;
      final hasAdditive = food['hasAdditive'] as bool;

      bool show = false;

      if (!(_filterAdditives || _filterAllergens || _filterSafe) ) {
        show = true;
      }

      if (_filterAllergens && hasAllergen) {
        show = true;
      }

      if (_filterAdditives && hasAdditive) {
        show = true;
      }

      if (_filterSafe && !hasAllergen && !hasAdditive) {
        show = true;
      }

      return show;
    }).toList();


    if (_selectedSort == "az") {
      filtered.sort((a, b) =>
          (a['foodName'] as String).toLowerCase().compareTo((b['foodName'] as String).toLowerCase()));
    } else if (_selectedSort == "za") {
      filtered.sort((a, b) =>
          (b['foodName'] as String).toLowerCase().compareTo((a['foodName'] as String).toLowerCase()));
    }

    return filtered;
  }

  Future<bool> _confirmRemoval(String foodName) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: Text("Do you want to remove \"$foodName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ?? false;
  }



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

  Future<void> refreshFoodAllergens() async {
    for (var food in foodInfo) {
      final ingredients = food['ingredients'] as String;
      final allergenTags = food['allergenTags'] as List<dynamic>;
      final traces = food['traces'] as List<dynamic>;

      final matchedAllergens = await UserPreferences.findMatchingAllergens(ingredients, allergenTags, traces);
      final matchedAdditives = await UserPreferences.findMatchingAdditives(ingredients);

      food['matchedAllergens'] = matchedAllergens;
      food['matchedAdditives'] = matchedAdditives;

      food['hasAllergen'] = matchedAllergens.isNotEmpty;
      food['hasAdditive'] = matchedAdditives.isNotEmpty;
    }

    setState(() {});
    await _saveFoods();
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
          'nutriments': parts.length > 2 ? _parseNutriments(parts[2]) : <String, dynamic>{},
          'allergenTags': parts.length > 3 ?
            (parts[3].isEmpty ? <Object>[] : parts[3].split(',').map((e) => e as Object).toList()) : <Object>[],
          'traces': parts.length > 4 ?
            (parts[4].isEmpty ? <Object>[] : parts[4].split(',').map((e) => e as Object).toList()) : <Object>[],
          'hasAllergen': parts.length > 5 ? parts[5].toLowerCase() == 'true' : false,
          'hasAdditive': parts.length > 6 ? parts[6].toLowerCase() == 'true' : false,
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
      await refreshFoodAllergens();
    } catch (e) {
      if (mounted) {
        setState(() {
          foodInfo = [];
        });
      }
    }
  }

  Map<String, dynamic> _parseNutriments(String nutrimentsStr) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(nutrimentsStr);
      return decoded;
    } catch (e) {
      print('Failed to parse nutriments: $e | input: $nutrimentsStr');
      return {};
    }
  }

  Future<void> _saveFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedFoods = foodInfo.map((food) {
        final nutriments = food['nutriments'] as Map<String, dynamic>;

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
          food['hasAdditive'].toString(),
        ].join('|');
      }).toList();

      await prefs.setStringList('foods_list', encodedFoods);
    } catch (e) {
      print('Error saving foods: $e');
    }
  }

  void _toggleExpand(Map<String, Object> food) {
    setState(() {
      food['expanded'] = !(food['expanded'] as bool);
    });
  }

  void _removeFood(Map<String, Object> food) {
    setState(() {
      foodInfo.remove(food); 
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
    final formattedNutriments = Map<String, dynamic>.from({
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

  Widget _buildFilterDropdown() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sort",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RadioListTile<String>(
            title: const Text("A → Z"),
            value: "az",
            groupValue: _selectedSort,
            onChanged: (v) {
              setState(() => _selectedSort = v);
            },
          ),
          RadioListTile<String>(
            title: const Text("Z → A"),
            value: "za",
            groupValue: _selectedSort,
            onChanged: (v) {
              setState(() => _selectedSort = v);
            },
          ),

          const SizedBox(height: 12),
          const Text(
            "Filters",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          CheckboxListTile(
            title: const Text("Show items with allergens"),
            value: _filterAllergens,
            onChanged: (v) {
              setState(() => _filterAllergens = v!);
            },
          ),
          CheckboxListTile(
            title: const Text("Show items with additives"),
            value: _filterAdditives,
            onChanged: (v) {
              setState(() => _filterAdditives = v!);
            },
          ),
          CheckboxListTile(
            title: const Text("Show safe foods"),
            value: _filterSafe,
            onChanged: (v) {
              setState(() => _filterSafe = v!);
            },
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _isFilterOpen = false;
                  _getFilteredSortedFoods();
                });
              },
            ),
          ),
        ],
      ),
    );
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
    final bool hasAdditive = food['hasAdditive'] as bool;
    final String foodName = food['foodName'] as String;
    final String ingredients = food['ingredients'] as String;
    final List<dynamic> allergenTags = food['allergenTags'] as List<dynamic>;
    final Map<String, dynamic> nutriments = food['nutriments'] as Map<String, dynamic>;
    final List<dynamic> matchedAdditives = (food['matchedAdditives'] as List<dynamic>? ?? []).cast<String>();

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final cardColor = hasAllergen
        ? (isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red[100])
        :hasAdditive
            ? (isDarkMode ? Colors.orange.withOpacity(0.2) : Colors.orange[100])
            : theme.cardColor;
    final textColor = hasAllergen
        ? (isDarkMode ? Colors.red[200] : Colors.red[900])
        :hasAdditive
            ? (isDarkMode ? Colors.orange[200] : Colors.orange[900])
            : theme.textTheme.bodyLarge?.color;
    final companyColor = hasAllergen
        ? (isDarkMode ? Colors.red[200] : Colors.red[700])
        :hasAdditive
            ? (isDarkMode ? Colors.orange[200] : Colors.orange[700])
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
            onTap: () => _toggleExpand(food),
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
                    onPressed: () async {
                      final confirm = await _confirmRemoval(foodName);
                      if (confirm) _removeFood(food);

                    }, 
                    color: textColor,
                  ),
                  IconButton(
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () => _toggleExpand(food),
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(16),
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
                  ] else if (hasAdditive) ...[
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'CONTAINS UNWANTED ADDITIVES',
                      style: TextStyle(
                        color: Colors.orange,
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

            const SizedBox(height: 1),

            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additives:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (matchedAdditives.isNotEmpty)
                    Text(
                      matchedAdditives.join(', '),
                      style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _calculateAdditiveLevel(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getAdditiveColor(_calculateAdditiveLevel()),
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
              ),
            ),

            Container(height: 1, color: Colors.black),

            ..._buildMacroNutrientBars(context, nutriments),

            const SizedBox(height: 1),

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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterOpen = !_isFilterOpen;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterOpen) _buildFilterDropdown(),

          Container(
            height: 1,
            color: Colors.black,
          ),
          Expanded(
            child: _getFilteredSortedFoods().isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _getFilteredSortedFoods().length,
                    itemBuilder: (context, index) =>
                        _buildFoodItem(_getFilteredSortedFoods()[index], index),
                  ),
          ),
        ],
      ),
    );
  }

 List<Widget> _buildMacroNutrientBars(BuildContext context, Map<String, dynamic> nutriments) {
    return [
      _buildNutrientBar(context, 'Protein', 'proteins_serving', 'proteins_100g', 'proteins', nutriments),
      Container(height: 1, color: Colors.black),
      _buildNutrientBar(context, 'Fats', 'fat_serving', 'fat_100g', 'fat', nutriments),
      Container(height: 1, color: Colors.black),
      _buildNutrientBar(context, 'Carbs', 'carbohydrates_serving', 'carbohydrates_100g', 'carbohydrates', nutriments),
      Container(height: 1, color: Colors.black),
    ];
  }

  Widget _buildNutrientBar(BuildContext context, String name, String primaryKey, String fallbackKey, String evenMoreFallback, Map<String, dynamic> nutriments) {
    double? value = _getNutrientValue([primaryKey, fallbackKey, evenMoreFallback, '${fallbackKey}_100g'], nutriments);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      child: value != null ?
        _buildNutrientWithBar(context, name, value) :
        _buildNutrientNotProvided(context, name),
    );
  }

  Widget _buildNutrientWithBar(BuildContext context, String name, double value) {
    final level = _calculateNutrientLevel(name, value);
    final description = _getNutrientDescription(name, level);
    final color = _getNutrientColor(level);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
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

  Widget _buildNutrientNotProvided(BuildContext context, String name) {
    final theme = Theme.of(context);
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
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
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

  double? _getNutrientValue(List<String> possibleKeys, Map<String, dynamic> nutriments) {
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
    if (value <= 0) return 0.0;

    Map<String, Map<String, double>> thresholds = {
      'Protein': {'low': 5.0, 'high': 20.0},
      'Fats': {'low': 3.0, 'high': 17.5},
      'Carbs': {'low': 5.0, 'high': 22.5},
    };

    final threshold = thresholds[nutrientName];
    if (threshold == null) return 0.5;

    if (value <= threshold['low']!) {
      return 0.25; // Low
    } else if (value >= threshold['high']!) {
      return 1.0; // High
    } else {

      final range = threshold['high']! - threshold['low']!;
      final position = (value - threshold['low']!) / range;
      return 0.25 + (position * 0.75);
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

  double _calculateAdditiveLevel() {
    if (matchedAdditives.isEmpty) return 0.2;
    if (matchedAdditives.length <= 2) return 0.4; //
    if (matchedAdditives.length <= 4) return 0.7; //
    return 1.0;
  }

  Color _getAdditiveColor(double level) {
    if (level <= 0.3) return Colors.green;
    if (level <= 0.6) return Colors.orange;
    return Colors.red;
  }

}