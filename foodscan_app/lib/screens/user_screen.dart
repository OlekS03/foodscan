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
          /// Allergens Card
          Card(
            color: Colors.blue[50],
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Allergens',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      allergensExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.yellow[700],
                    ),
                    onPressed: () => setState(() {
                      allergensExpanded = !allergensExpanded;
                    }),
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
                            onPressed: () {
                              setState(() {
                                allergens.removeAt(i);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          /// Additives Card
          Card(
            color: Colors.blue[50],
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Additives',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      additivesExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.yellow[700],
                    ),
                    onPressed: () => setState(() {
                      additivesExpanded = !additivesExpanded;
                    }),
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
                            onPressed: () {
                              setState(() {
                                additives.removeAt(i);
                              });
                            },
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

