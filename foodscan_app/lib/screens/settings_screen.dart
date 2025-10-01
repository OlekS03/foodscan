import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Enable dark theme'),
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Enable push notifications'),
                      value: _notifications,
                      onChanged: (bool value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Language'),
                      subtitle: Text(_selectedLanguage),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Implement language selection
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF432222)
                    : Colors.red[50],
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    // TODO: Implement sign out
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
