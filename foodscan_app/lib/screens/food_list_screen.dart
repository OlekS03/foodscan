import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; /// Needed to save data between sessions.

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
    _loadFoods(); // Load saved data when the screen starts.
  }

  /// Loads the list of foods from SharedPreferences.
  Future<void> _loadFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedFoods = prefs.getStringList('foods_list');

    // If nothing is saved yet, start with an empty list
    if (savedFoods == null || savedFoods.isEmpty) {
      setState(() {
        foods = [];
      });
      return;
    }

    // Decode saved data
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


  /// Saves the current list of foods to SharedPreferences.
  Future<void> _saveFoods() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert Map list into a simple String list for storage
    List<String> dataToSave = foods.map((food) {
      final name = food['name'];
      final info = (food['info'] as List).join(',');
      return '$name|$info';
    }).toList();

    await prefs.setStringList('foods_list', dataToSave);
  }

  void _toggleExpand(int index) {
    setState(() {
      foods[index]['expanded'] = !(foods[index]['expanded'] as bool);
    });
  }

  void _removeFood(int index) async {
    setState(() {
      foods.removeAt(index);
    });
    await _saveFoods(); // Persist change
  }

  /// Adds a new food entry with name and info.
  void addFood(String name, List<String> info) async {
    setState(() {
      foods.add({'name': name, 'info': info, 'expanded': false});
    });
    await _saveFoods(); // Persist change
  }

  /// Dialog to add a new food manually For Testing.
  Future<void> _showAddFoodDialog(BuildContext context) async {
    String name = '';
    String info = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Food (Test)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Food name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Info (comma-separated)'),
                onChanged: (value) => info = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  addFood(name, info.isNotEmpty ? info.split(',') : []);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Food List'),
        backgroundColor: Colors.blue[400],
      ),
      body: ListView.builder(
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
                  title: Text(
                    food['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          food['expanded'] ? Icons.expand_less : Icons.expand_more,
                          color: Colors.yellow[700],
                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFoodDialog(context),
        backgroundColor: Colors.blue[400],
        child: const Icon(Icons.add),
      ),
    );
  }
}

