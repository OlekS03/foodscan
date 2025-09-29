import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool allergensExpanded = false;
  bool additivesExpanded = false;

  final List<String> allergens = ['Peanuts', 'Gluten', 'Lactose'];
  final List<String> additives = ['Yellow 5', 'High-fructose corn syrup', 'MSG'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F2FD),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue[50],
            child: ListTile(
              title: const Text(
                'Username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Implement settings
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                      IconButton(
                        icon: Icon(
                          allergensExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.yellow[700],
                        ),
                        onPressed: () => setState(() => allergensExpanded = !allergensExpanded),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          // TODO: Implement remove allergens
                        },
                      ),
                    ],
                  ),
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
                          color: Colors.yellow[700],
                        ),
                        onPressed: () => setState(() => additivesExpanded = !additivesExpanded),
                      ),
                      IconButton(
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
