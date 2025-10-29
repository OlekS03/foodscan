import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Handle error if needed
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Icon(
              Icons.no_food,
              size: 80,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Food List is Empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(178),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan a food item to get started!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, Object> food, int index, bool isDarkMode) {
    final cardColor = food['hasAllergen'] == true
        ? (isDarkMode
            ? const Color.fromARGB(255, 182, 35, 30)
            : const Color.fromARGB(255, 255, 200, 200))
        : (isDarkMode
            ? Theme.of(context).cardColor
            : Colors.blue[50]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: food['expanded'] as bool ? 4 : 1,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        color: cardColor,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                food['foodName'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _controller,
                      color: isDarkMode ? Colors.tealAccent : Colors.yellow[700],
                    ),
                    onPressed: () {
                      _toggleExpand(index);
                      food['expanded'] as bool
                          ? _controller.forward()
                          : _controller.reverse();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: isDarkMode ? Colors.redAccent : Colors.red,
                    ),
                    onPressed: () => _removeFood(index),
                  ),
                ],
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: food['expanded'] as bool
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _buildInfoSection('Ingredients', food['ingredients'] as String),
                            if ((food['allergenTags'] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoSection('Allergens', (food['allergenTags'] as List).join(', ')),
                            ],
                            if ((food['traces'] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoSection('May Contain', (food['traces'] as List).join(', ')),
                            ],
                            if ((food['nutriments'] as Map).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoSection('Nutrition', _formatNutriments(food['nutriments'] as Map<String, dynamic>)),
                            ],
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
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
        body: RefreshIndicator(
          onRefresh: _loadFoods,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: foodInfo.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: foodInfo.length,
                    itemBuilder: (context, i) => _buildFoodCard(foodInfo[i], i, isDarkMode),
                  ),
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
