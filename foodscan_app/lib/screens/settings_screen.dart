import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Preferences Section
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text(
                      'Preferences',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) => Column(
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
                              value: true, // TODO: Implement notifications state
                              onChanged: (bool value) {
                                // TODO: Implement notifications toggle
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Auto-Save Scans'),
                              subtitle: const Text('Automatically save scanned items'),
                              value: false, // TODO: Implement auto-save state
                              onChanged: (bool value) {
                                // TODO: Implement auto-save toggle
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Allergen Alerts'),
                              subtitle: const Text('Notify me about allergens in scanned items'),
                              value: true, // TODO: Implement allergen alerts state
                              onChanged: (bool value) {
                                // TODO: Implement allergen alerts toggle
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Location Services'),
                              subtitle: const Text('Enable location-based features'),
                              value: false, // TODO: Implement location services state
                              onChanged: (bool value) {
                                // TODO: Implement location services toggle
                              }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Help Section
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help'),
                    children: [
                      ListTile(
                        title: const Text('How do I scan food?'),
                        subtitle: const Text('Open the camera tab and point your camera at the food\'s barcode'),
                      ),
                      ListTile(
                        title: const Text('How do I add allergens?'),
                        subtitle: const Text('Go to your profile and tap the allergens section to add new items'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Contact Support'),
                        subtitle: const Text('support@foodscan.app'),
                      ),
                      ListTile(
                        title: const Text('Version'),
                        subtitle: const Text('1.0.0'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Delete Account Section
                Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF432222)
                      : Colors.red[50],
                  child: ExpansionTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Warning: This action cannot be undone',
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                      'Are you sure you want to delete your account? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Implement account deletion
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Delete Account'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
