import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => FoodListScreenState();
}

class FoodListScreenState extends State<FoodListScreen> {
  List<Map<String, dynamic>> foodInfo = [];

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

    final loadedFoods = savedFoods.map((item) {
      final parts = item.split('|');
      return {
        'foodName': parts[0],
        'ingredients': parts.length > 1 ? parts[1] : '',
        'nutriments': parts.length > 2 ? _parseNutriments(parts[2]) : {},
        'allergenTags': parts.length > 3 ? parts[3].split(',') : [],
        'traces': parts.length > 4 ? parts[4].split(',') : [],
        'hasAllergen': parts.length > 5 ? parts[5] == 'true' : false,
        'expanded': false,
      };
    }).toList();

    if (mounted) {
      setState(() {
        foodInfo = loadedFoods;
      });
    }
  }

  Map<String, dynamic> _parseNutriments(String nutrimentsStr) {
    try {
      final pairs = nutrimentsStr.split(',');
      final map = <String, dynamic>{};
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          map[keyValue[0]] = double.tryParse(keyValue[1]) ?? keyValue[1];
        }
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedFoods = foodInfo.map((food) {
      final nutrimentStr = food['nutriments'].entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');

      return [
        food['foodName'],
        food['ingredients'],
        nutrimentStr,
        (food['allergenTags'] as List).join(','),
        (food['traces'] as List).join(','),
        food['hasAllergen'].toString(),
      ].join('|');
    }).toList();

    await prefs.setStringList('foods_list', encodedFoods);
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
        'foodName': foodName,
        'ingredients': ingredients,
        'nutriments': nutriments,
        'allergenTags': allergenTags,
        'traces': traces,
        'hasAllergen': hasAllergen,
        'expanded': false,
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
