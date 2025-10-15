import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/food_list_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/user_screen.dart';
import 'providers/theme_provider.dart';
import 'screens/food_list_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/user_screen.dart';
import 'global_keys.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  //We are forcing the list screen to be build durring initalization so the
  //respondToBarcodeRetrieval function can make the call to the food_list_screen's
  //addFoodItemToList function.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      foodListKey.currentState?.setState(() {});
    });
  }

  int _selectedIndex = 1;
  final List<Widget> _screens = [
    FoodListScreen(key: foodListKey),
    const BarcodeScannerPage(),
    const UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //BUG: only one active tab's widget exists in tree
  //      children die/cease every time the tab is changed
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      body: _screens[_selectedIndex],
      */
      body: IndexedStack(
      index: _selectedIndex,
      children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
            backgroundColor: Colors.green,
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Foodscan',
        theme: themeProvider.theme,
        home: const MainScaffold(),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const FoodListScreen(),
    const CameraScreenUI(),
    const UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
            backgroundColor: Colors.red,
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.shifting,
      ),
    return MaterialApp(
      title: 'Foodscan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}
