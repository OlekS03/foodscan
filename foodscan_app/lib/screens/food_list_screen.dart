import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});
  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  List<Map<String, dynamic>> foods = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }
  State<FoodListScreen> createState() => FoodListScreenState();
}

final Map<String, String> titles = {
  "ingredients": "Ingredients",
  "allergens": "Allergens",
  "traceAllergens": "traceAllergens",
};
  Future<void> _loadFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedFoods = prefs.getStringList('foods_list');

    if (savedFoods == null || savedFoods.isEmpty) {
      setState(() {
        foods = [];
      });
      return;
    }

    setState(() {
      foods = savedFoods.map((item) {
        final parts = item.split('|');
        final name = parts.isNotEmpty ? parts[0] : '';
        final info = parts.length > 1 && parts[1].isNotEmpty
            ? parts[1].split(',')
            : <String>[];
        return {
          'name': name,
          'info': info,
          'expanded': false,
        };
      }).toList();
    });
  }

class FoodListScreenState extends State<FoodListScreen> {
  List<Map<String, dynamic>>? foodInfo = [];
  Future<void> _saveFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedFoods = foods.map((food) {
      final name = food['name'] as String;
      final info = (food['info'] as List<String>).join(',');
      return '$name|$info';
    }).toList();
    await prefs.setStringList('foods_list', encodedFoods);
  }

  void _toggleExpand(int index) {
    setState(() {
      bool isExpanded = foodInfo?[index]['expanded'] ?? false;
      foodInfo?[index]['expanded'] = !isExpanded;
      foods[index]['expanded'] = !(foods[index]['expanded'] as bool);
    });
  }

  void _removeFood(int index) {
    setState(() {
      foodInfo?.removeAt(index);
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
    print("inside addItemToFoodsList");
    setState(() {
      Map<String, dynamic> foodItem = {
        'foodName': foodName,
        'ingredients': ingredients,
        'nutriments': nutriments,
        'allergenTags': allergenTags,
        'traces': traces,
        'hasAllergen': hasAllergen,
      };
      foodInfo?.add(foodItem);
      foods.removeAt(index);
    });
    _saveFoods(); // Save changes after removing item
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: foods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_food,
                    size: 64,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No foods added yet',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              itemCount: foods.length,
              itemBuilder: (context, i) {
                final food = foods[i];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          food['name'],
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
                                food['expanded'] ? Icons.expand_less : Icons.expand_more,
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
                      if (food['expanded']) ...[
                        for (final info in food['info'])
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              info,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
      color: const Color(0xFFE3F2FD),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        itemCount: foodInfo?.length,
        itemBuilder: (context, i) {
          final food = foodInfo?[i];
          var cardColor = Colors.blue[50];
          if ((food?['hasAllergen'] ?? false)) {
            cardColor = const Color.fromARGB(255, 182, 35, 30);
          }

          return Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),

            child: Column(
              children: [
                ListTile(
                  title: Text(
                    food?['foodName'] ?? 'Unknown food',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          (food?['expanded'] ?? false)
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.yellow[700],
                        ),
                        onPressed: () => _toggleExpand(i),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeFood(i),
                      ),
                    ],
                  ),
                ),

                if (food?['expanded'] ?? false) ...[
                  // Ingredients
                  if (food?['ingredients'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${titles['ingredients']}: ${food?['ingredients'] ?? 'No ingredients available'}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),

                  // Allergen Tags
                  if (food?['allergenTags'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${titles['allergens']}: ${food?['allergenTags']?.join(', ')}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),

                  // Trace Tags
                  if (food?['traces'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${titles['traceAllergens']}: ${food?['traces']?.join(', ')}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
