import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:mockito/mockito.dart';
//import 'package:mockito/annotations.dart';

import 'package:foodscan_app/screens/food_list_screen.dart';
//import 'package:foodscan_app/services/user_preferences.dart';

//import 'food_list_screen_test.mocks.dart';

//@GenerateMocks([UserPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Shows empty state when no foods stored', (tester) async {
    SharedPreferences.setMockInitialValues({}); // nothing saved

    await tester.pumpWidget(
      MaterialApp(home: FoodListScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Food List is Currently Empty'), findsOneWidget);
  });


   
}