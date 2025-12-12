import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/food_list_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/user_screen.dart';
import 'providers/theme_provider.dart';
import 'global_keys.dart';
import '../services/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FoodScan',
          theme: themeProvider.theme,
          home: MainScaffold(key: mainScaffoldKey),
        );
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;

  final FoodListScreen _foodListScreen = FoodListScreen(key: foodListKey);
  final CameraScreen _cameraScreen = const CameraScreen();
  final UserScreen _userScreen = UserScreen(key: userScreenKey);

  Future<void> onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        foodListKey.currentState?.reloadFoods();
      }
    });

    bool isNew = await UserPreferences.isNewUserProfile();
    if (index == 2 && isNew) {
      userScreenKey.currentState?.checkProfileUserPopup();
    }
  }

  Future<void> switchToProfileTab() async {
    setState(() {
      _selectedIndex = 2;
    });

    bool isNew = await UserPreferences.isNewUserProfile();
    if (isNew) {
      userScreenKey.currentState?.checkProfileUserPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _foodListScreen,
          _cameraScreen,
          _userScreen,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: onItemTapped,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Food List',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
