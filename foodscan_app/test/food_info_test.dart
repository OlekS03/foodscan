//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:foodscan_app/main.dart';
import 'package:foodscan_app/food_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){

  TestWidgetsFlutterBinding.ensureInitialized();

  test('if item is a nonfood item make sure it returns correctly', () async{
      SharedPreferences.setMockInitialValues({});


      final foodInfo = await ingredientsAndNutrimentsFromBarcode('1204403759');

      expect(foodInfo, null);
  });

  test('handling junk URLs making sure it returns correctly', () async{
      SharedPreferences.setMockInitialValues({});


      final foodInfo = await ingredientsAndNutrimentsFromBarcode('not real.com');

      expect(foodInfo, null);
  });
}