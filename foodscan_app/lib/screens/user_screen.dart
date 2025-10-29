import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import '../services/user_preferences.dart';

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
    final loadedAllergens = await UserPreferences.getAllergens();
    final loadedAdditives = await UserPreferences.getAdditives();

    setState(() {
      allergens = loadedAllergens;
      additives = loadedAdditives;
    });
  }

  Future<void> _showAddDialog(String type) async {
    String newItem = '';

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

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergens', allergens);
    await prefs.setStringList('user_additives', additives);

    // Show a confirmation snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildExpandableSection(
    String title,
    List<String> items,
    bool isExpanded,
    Function(bool) onExpanded,
    Function() onAdd,
    Function(int) onRemove,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
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
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => onExpanded(!isExpanded),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          if (isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index],
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => onRemove(index),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('User Profile'),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
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
          _buildExpandableSection(
            'Allergens',
            allergens,
            allergensExpanded,
            (value) => setState(() => allergensExpanded = value),
            () => _showAddDialog('allergen'),
            (index) => _removeItem('allergen', index),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            'Additives to Avoid',
            additives,
            additivesExpanded,
            (value) => setState(() => additivesExpanded = value),
            () => _showAddDialog('additive'),
            (index) => _removeItem('additive', index),
          ),
        ],
      ),
    );
  }
}
