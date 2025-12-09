import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_preferences.dart';
import 'settings_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  List<String> allergens = [];
  List<String> additives = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void checkProfileUserPopup() async {
    
    bool isNew = await UserPreferences.isNewUserProfile();

    if (isNew && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final theme = Theme.of(context);
            final isDarkMode = theme.brightness == Brightness.dark;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Center(
                child: Text(
                  "WELCOME!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Here you can add your known allergens and unwanted additives, and we will alert you when you scan a food containing them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.tealAccent[700] : Colors.green[600],
                    foregroundColor: Colors.white,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await UserPreferences.setNewUserProfileFalse();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }


  Future<bool> _confirmRemoval(String item) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: Text("Do you want to remove \"$item\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ?? false;
  }


  Future<void> _loadPreferences() async {
    final loadedAllergens = await UserPreferences.getAllergens();
    final loadedAdditives = await UserPreferences.getAdditives();

    if (mounted) {
      setState(() {
        allergens = loadedAllergens;
        additives = loadedAdditives;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          _buildProfileHeader(theme),
          const Divider(),
          _buildPreferenceSection(
            title: 'Allergen Alerts',
            icon: Icons.warning_amber_rounded,
            items: allergens,
            onAdd: _addAllergen,
            onRemove: _removeAllergen,
            theme: theme,
          ),
          const Divider(),
          _buildPreferenceSection(
            title: 'Additive Alerts',
            icon: Icons.science_rounded,
            items: additives,
            onAdd: _addAdditive,
            onRemove: _removeAdditive,
            theme: theme,
          ),
          const Divider(),
          _buildSettingsSection(theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.person,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FoodScan User',
            style: theme.textTheme.headlineSmall,
          ),
          Text(
            'Manage your food preferences',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: () => _showAddDialog(title, onAdd),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              'No items added',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () async {
                    final confirm = await _confirmRemoval(item);
                    if (confirm) onRemove(item);
                  },
                  backgroundColor: theme.colorScheme.primaryContainer,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Settings', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.settings_applications),
            title: const Text('App Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(String title, Function(String) onAdd) async {
    String newItem = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${title.split(" ")[0]}'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter ${title.split(" ")[0].toLowerCase()}',
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
                onAdd(newItem);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addAllergen(String allergen) {
    setState(() {
      allergens.add(allergen);
      UserPreferences.setAllergens(allergens);
    });
  }

  void _removeAllergen(String allergen) {
    setState(() {
      allergens.remove(allergen);
      UserPreferences.setAllergens(allergens);
    });
  }

  void _addAdditive(String additive) {
    setState(() {
      additives.add(additive);
      UserPreferences.setAdditives(additives);
    });
  }

  void _removeAdditive(String additive) {
    setState(() {
      additives.remove(additive);
      UserPreferences.setAdditives(additives);
    });
  }
}
