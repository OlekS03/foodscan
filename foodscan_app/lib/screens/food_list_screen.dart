import 'package:flutter/material.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});
  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final List<Map<String, dynamic>> foods = [
    {
      'name': 'Apple',
      'info': ['Rich in fiber', 'Good for heart'],
      'expanded': false,
    },
    {
      'name': 'Bread',
      'info': ['Contains gluten', 'High carbs'],
      'expanded': false,
    },
  ];

  void _toggleExpand(int index) {
    setState(() {
      foods[index]['expanded'] = !(foods[index]['expanded'] as bool);
    });
  }

  void _removeFood(int index) {
    setState(() {
      foods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
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
    );
  }
}
