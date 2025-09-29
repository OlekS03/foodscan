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
    return Container(
      color: const Color(0xFFE3F2FD),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        itemCount: foods.length,
        itemBuilder: (context, i) {
          final food = foods[i];
          return Card(
            color: Colors.blue[50],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: Text(food['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(food['expanded'] ? Icons.expand_less : Icons.expand_more, color: Colors.yellow[700]),
                        onPressed: () => _toggleExpand(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                      child: Text(info, style: const TextStyle(color: Colors.black87)),
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
