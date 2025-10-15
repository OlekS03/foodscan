import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAllergens = prefs.getStringList('user_allergens');
    final savedAdditives = prefs.getStringList('user_additives');

    setState(() {
      allergens = savedAllergens ?? ['Peanuts', 'Gluten', 'Lactose'];
      additives = savedAdditives ?? ['Yellow 5', 'High-fructose corn syrup', 'MSG'];
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergens', allergens);
    await prefs.setStringList('user_additives', additives);
  }

  Future<void> _showAddDialog(String type) async {
    String newItem = '';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add new $type'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter name',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => newItem = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (newItem.isNotEmpty) {
                setState(() {
                  if (type == 'allergen') {
                    allergens.add(newItem);
                  } else {
                    additives.add(newItem);
                  }
                });
                _saveData();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeItem(String type, int index) {
    setState(() {
      if (type == 'allergen') {
        allergens.removeAt(index);
      } else {
        additives.removeAt(index);
      }
    });
    _saveData();
  }
  final List<String> allergens = ['Peanuts', 'Gluten', 'Lactose'];
  final List<String> additives = ['Yellow 5', 'High-fructose corn syrup', 'MSG'];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: const Color(0xFFE3F2FD),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue[50],
            color: Theme.of(context).cardColor,
            child: ListTile(
              title: const Text(
                'Username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Implement settings
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: Colors.blue[50],
            color: Theme.of(context).cardColor,
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
                      IconButton(
                        icon: Icon(
                          allergensExpanded ? Icons.expand_less : Icons.expand_more,
                          color: isDarkMode ? Colors.tealAccent : Colors.yellow[700],
                          color: Colors.yellow[700],
                        ),
                        onPressed: () => setState(() => allergensExpanded = !allergensExpanded),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          // TODO: Implement remove allergens
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: isDarkMode ? Colors.tealAccent : Theme.of(context).primaryColor,
                        ),
                        onPressed: () => _showAddDialog('allergen'),
                      ),
                    ],
                  ),
                ),
                if (allergensExpanded)
                  for (var i = 0; i < allergens.length; i++)
                    ListTile(
                      dense: true,
                      title: Text(allergens[i]),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: isDarkMode ? Colors.redAccent : Colors.red,
                        ),
                        onPressed: () => _removeItem('allergen', i),
                      ),
                if (allergensExpanded) ...[
                  for (final allergen in allergens)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(allergen),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: Colors.blue[50],
            color: Theme.of(context).cardColor,
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
                      IconButton(
                        icon: Icon(
                          additivesExpanded ? Icons.expand_less : Icons.expand_more,
                          color: isDarkMode ? Colors.tealAccent : Colors.yellow[700],
                          color: Colors.yellow[700],
                        ),
                        onPressed: () => setState(() => additivesExpanded = !additivesExpanded),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: isDarkMode ? Colors.tealAccent : Theme.of(context).primaryColor,
                        ),
                        onPressed: () => _showAddDialog('additive'),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          // TODO: Implement remove additives
                        },
                      ),
                    ],
                  ),
                ),
                if (additivesExpanded) ...[
                  for (final additive in additives)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(additive),
                if (additivesExpanded)
                  for (var i = 0; i < additives.length; i++)
                    ListTile(
                      dense: true,
                      title: Text(additives[i]),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: isDarkMode ? Colors.redAccent : Colors.red,
                        ),
                        onPressed: () => _removeItem('additive', i),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
