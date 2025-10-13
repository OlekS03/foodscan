import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool allergensExpanded = false;
  bool additivesExpanded = false;

  List<String> allergens = [];
  List<String> additives = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load saved data
  }

  /// Load allergens and additives from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedAllergens = prefs.getStringList('user_allergens');
    final savedAdditives = prefs.getStringList('user_additives');

    setState(() {
      allergens = savedAllergens ?? ['Peanuts', 'Gluten', 'Lactose'];
      additives = savedAdditives ?? ['Yellow 5', 'High-fructose corn syrup', 'MSG'];
    });
  }

  /// Save both lists to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergens', allergens);
    await prefs.setStringList('user_additives', additives);
  }

  /// Show dialog to add a new item
  Future<void> _showAddDialog(String type) async {
    String newItem = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new $type'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Enter $type name',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => newItem = value.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newItem.isNotEmpty) {
                  setState(() {
                    if (type == 'allergen') {
                      allergens.add(newItem);
                    } else {
                      additives.add(newItem);
                    }
                  });
                  await _saveData();
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

  /// Remove item and save
  Future<void> _removeItem(String type, int index) async {
    setState(() {
      if (type == 'allergen') {
        allergens.removeAt(index);
      } else {
        additives.removeAt(index);
      }
    });
    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F2FD),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== ALLERGENS CARD =====
          Card(
            color: Colors.blue[50],
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Allergens',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add new allergen button
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _showAddDialog('allergen'),
                      ),
                      // Expand/collapse button
                      IconButton(
                        icon: Icon(
                          allergensExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.yellow[700],
                        ),
                        onPressed: () =>
                            setState(() => allergensExpanded = !allergensExpanded),
                      ),
                    ],
                  ),
                ),
                if (allergensExpanded)
                  Column(
                    children: [
                      for (int i = 0; i < allergens.length; i++)
                        ListTile(
                          title: Text(allergens[i]),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeItem('allergen', i),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===== ADDITIVES CARD =====
          Card(
            color: Colors.blue[50],
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Additives',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add new additive button
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _showAddDialog('additive'),
                      ),
                      // Expand/collapse button
                      IconButton(
                        icon: Icon(
                          additivesExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.yellow[700],
                        ),
                        onPressed: () =>
                            setState(() => additivesExpanded = !additivesExpanded),
                      ),
                    ],
                  ),
                ),
                if (additivesExpanded)
                  Column(
                    children: [
                      for (int i = 0; i < additives.length; i++)
                        ListTile(
                          title: Text(additives[i]),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeItem('additive', i),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
