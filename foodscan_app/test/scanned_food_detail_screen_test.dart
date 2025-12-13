import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodscan_app/screens/scanned_food_detail_screen.dart';

void main() {
  group('ScannedFoodDetailScreen tests', () {
    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    
    testWidgets('companyName does not render when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ScannedFoodDetailScreen(
            foodName: 'Food',
            companyName: null, // null case
            ingredients: 'Ingredients',
            nutriments: {},
            allergenTags: [],
            traces: [],
            matchedAllergens: [],
            matchedAdditives: [],
            imageUrl: null,
          ),
        ),
      );

      expect(find.text('Company:'), findsNothing);
    });
  });
}
