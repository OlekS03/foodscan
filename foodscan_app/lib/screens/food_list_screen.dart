import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => FoodListScreenState();
}

class FoodListScreenState extends State<FoodListScreen> {
  List<Map<String, Object>> foodInfo = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
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
      print('Error loading foods: $e');
      if (mounted) {
        setState(() {
          foodInfo = [];
        });
      }
    }
  }

  Map<String, Object> _parseNutriments(String nutrimentsStr) {
    try {
      if (nutrimentsStr.isEmpty) return {};

      final pairs = nutrimentsStr.split(',');
      final map = <String, Object>{};
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final value = double.tryParse(keyValue[1]) ?? keyValue[1];
          map[keyValue[0]] = value;
        }
      }
      return map;
    } catch (e) {
      print('Error parsing nutriments: $e');
      return {};
    }
  }

  Future<void> _saveFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedFoods = foodInfo.map((food) {
        // Convert nutriments to string format
        final nutriments = food['nutriments'] as Map<String, Object>;
        final nutrimentStr = nutriments.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');

        // Convert lists to string format
        final allergenTags = (food['allergenTags'] as List).join(',');
        final traces = (food['traces'] as List).join(',');

        // Create the encoded string
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
    setState(() {
      foodInfo.add({
        'foodName': foodName as Object,
        'ingredients': ingredients as Object,
        'nutriments': Map<String, Object>.from(nutriments),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food List'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: foodInfo.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_food,
                        size: 64,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No foods added yet',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  itemCount: foodInfo.length,
                  itemBuilder: (context, i) {
                    final food = foodInfo[i];
                    var cardColor = isDarkMode
                        ? Theme.of(context).cardColor
                        : Colors.blue[50];

                    if (food['hasAllergen'] == true) {
                      cardColor = isDarkMode
                          ? const Color.fromARGB(255, 182, 35, 30)
                          : const Color.fromARGB(255, 255, 200, 200);
                    }

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              food['foodName'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    food['expanded'] as bool ? Icons.expand_less : Icons.expand_more,
                                    color: isDarkMode ? Colors.tealAccent : Colors.yellow[700],
                                  ),
                                  onPressed: () => _toggleExpand(i),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: isDarkMode ? Colors.redAccent : Colors.red,
                                  ),
                                  onPressed: () => _removeFood(i),
                                ),
                              ],
                            ),
                          ),
                          if (food['expanded'] as bool) ...[
                            _buildInfoSection('Ingredients', food['ingredients'] as String),
                            if ((food['allergenTags'] as List).isNotEmpty)
                              _buildInfoSection('Allergens', (food['allergenTags'] as List).join(', ')),
                            if ((food['traces'] as List).isNotEmpty)
                              _buildInfoSection('May Contain', (food['traces'] as List).join(', ')),
                            if ((food['nutriments'] as Map).isNotEmpty)
                              _buildInfoSection('Nutrition', _formatNutriments(food['nutriments'] as Map<String, dynamic>)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  String _formatNutriments(Map<String, dynamic> nutriments) {
    return nutriments.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }
}
