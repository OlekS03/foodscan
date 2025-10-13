import 'package:flutter/material.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});
  @override
  State<FoodListScreen> createState() => FoodListScreenState();
}

final Map<String, String> titles = {
  "ingredients": "Ingredients",
  "allergens": "Allergens",
  "traceAllergens": "traceAllergens",
};

class FoodListScreenState extends State<FoodListScreen> {
  List<Map<String, dynamic>>? foodInfo = [];

  void _toggleExpand(int index) {
    setState(() {
      bool isExpanded = foodInfo?[index]['expanded'] ?? false;
      foodInfo?[index]['expanded'] = !isExpanded;
    });
  }

  void _removeFood(int index) {
    setState(() {
      foodInfo?.removeAt(index);
    });
  }

  void addItemToFoodsList(
    String foodName,
    String ingredients,
    Map<String, dynamic> nutriments,
    List<dynamic> allergenTags,
    List<dynamic> traces,
    bool hasAllergen,
  ) {
    print("inside addItemToFoodsList");
    setState(() {
      Map<String, dynamic> foodItem = {
        'foodName': foodName,
        'ingredients': ingredients,
        'nutriments': nutriments,
        'allergenTags': allergenTags,
        'traces': traces,
        'hasAllergen': hasAllergen,
      };
      foodInfo?.add(foodItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F2FD),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        itemCount: foodInfo?.length,
        itemBuilder: (context, i) {
          final food = foodInfo?[i];
          var cardColor = Colors.blue[50];
          if ((food?['hasAllergen'] ?? false)) {
            cardColor = const Color.fromARGB(255, 182, 35, 30);
          }

          return Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),

            child: Column(
              children: [
                ListTile(
                  title: Text(
                    food?['foodName'] ?? 'Unknown food',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          (food?['expanded'] ?? false)
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.yellow[700],
                        ),
                        onPressed: () => _toggleExpand(i),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeFood(i),
                      ),
                    ],
                  ),
                ),

                if (food?['expanded'] ?? false) ...[
                  // Ingredients
                  if (food?['ingredients'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${titles['ingredients']}: ${food?['ingredients'] ?? 'No ingredients available'}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),

                  // Allergen Tags
                  if (food?['allergenTags'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${titles['allergens']}: ${food?['allergenTags']?.join(', ')}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),

                  // Trace Tags
                  if (food?['traces'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${titles['traceAllergens']}: ${food?['traces']?.join(', ')}",
                        style: const TextStyle(color: Colors.black87),
                      ),
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
