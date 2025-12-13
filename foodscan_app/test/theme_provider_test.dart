//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:foodscan_app/main.dart';
import 'package:foodscan_app/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){

  TestWidgetsFlutterBinding.ensureInitialized();

  test('ThemeProvider loads initial preference and toggles dark mode', () async {
    // Start shared prefs with no stored value
    SharedPreferences.setMockInitialValues({});

    final themeProvider = ThemeProvider();

    // Allow async constructor work to finish
    await Future.delayed(const Duration(milliseconds: 10));

    // Dark mode should start false
    expect(themeProvider.isDarkMode, isFalse);

    // Toggle theme
    await themeProvider.toggleTheme();
    expect(themeProvider.isDarkMode, isTrue);

    // Check it saved preference
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDarkMode'), isTrue);

    // Toggle again
    await themeProvider.toggleTheme();
    expect(themeProvider.isDarkMode, isFalse);
  });

  test('ThemeProvider loads initial preference and checks if it by default is light mode', () async {
    // Start shared prefs with no stored value
    SharedPreferences.setMockInitialValues({});

    final themeProvider = ThemeProvider();

    // Allow async constructor work to finish
    await Future.delayed(const Duration(milliseconds: 10));

    // since the preference isn't updated returns null
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDarkMode'), null);

    // Dark mode should start false
    expect(themeProvider.isDarkMode, isFalse);
  });

  test('testing if _loadthemepreference works properly', () async{
    SharedPreferences.setMockInitialValues({'isDarkMode': true});
    final themeProvider = ThemeProvider();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(themeProvider.isDarkMode, isTrue);
  });

  test('testing if _loadthemepreference works properly and then toggling switches to the correct theme', () async{
    SharedPreferences.setMockInitialValues({'isDarkMode': true});
    final themeProvider = ThemeProvider();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(themeProvider.isDarkMode, isTrue);

    // checks if toggle works with initial variable set
    await themeProvider.toggleTheme();
    expect(themeProvider.isDarkMode, isFalse);

    //checks if after toggle sharedprefence is able to save it correctly
    final pref = await SharedPreferences.getInstance();
    expect(pref.getBool('isDarkMode'), isFalse);

  });
}


