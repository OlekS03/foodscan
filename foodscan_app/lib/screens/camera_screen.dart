import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/food_info.dart';
import '../screens/food_list_screen.dart';
import '../global_keys.dart';
import '../services/user_preferences.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanning = false;
  final MobileScannerController _controller = MobileScannerController();
  String? barcodeResult = '';
  bool optOutFlag = false;

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _loadWarningPrompt(
    BuildContext context,
    String foodName,
    String ingredients,
    Map<String, dynamic> nutriments,
    List<dynamic> allergenTags,
    List<dynamic> traces,
    List<String> matchedAllergens,
    List<String> matchedAdditives,
  ) {
    String warningMessage = '';
    if (matchedAllergens.isNotEmpty) {
      warningMessage += 'Allergens found: ${matchedAllergens.join(", ")}\n';
    }
    if (matchedAdditives.isNotEmpty) {
      warningMessage += 'Additives found: ${matchedAdditives.join(", ")}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(warningMessage),
              const SizedBox(height: 16),
              const Text('Would you like to add this item anyway?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                foodListKey.currentState?.addItemToFoodsList(
                  foodName,
                  ingredients,
                  nutriments,
                  allergenTags,
                  traces,
                  true,
                );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _handleBarcodeScan(String barcode) async {
    final foodInfo = await ingredientsAndNutrimentsFromBarcode(barcode);

    if (foodInfo != null && mounted) {
      final foodName = foodInfo['food_name'] as String;
      final ingredients = foodInfo['ingredients'] as String? ?? 'No ingredients listed';
      final nutriments = foodInfo['nutriments'] as Map<String, dynamic>? ?? {};
      final allergenTags = foodInfo['allergen_tags'] as List<dynamic>? ?? [];
      final traces = foodInfo['traces'] as List<dynamic>? ?? [];

      // Check for allergens and additives
      final matchedAllergens = await UserPreferences.findMatchingAllergens(
        ingredients,
        allergenTags,
        traces,
      );
      final matchedAdditives = await UserPreferences.findMatchingAdditives(
        ingredients,
      );

      if (!mounted) return;

      // Show warning if matches found
      if (matchedAllergens.isNotEmpty || matchedAdditives.isNotEmpty) {
        _loadWarningPrompt(
          context,
          foodName,
          ingredients,
          nutriments,
          allergenTags,
          traces,
          matchedAllergens,
          matchedAdditives,
        );
      } else {
        // No allergens or additives found, add item directly
        foodListKey.currentState?.addItemToFoodsList(
          foodName,
          ingredients,
          nutriments,
          allergenTags,
          traces,
          false,
        );
      }
    }
  }

  void _showTestBarcodeDialog() {
    String barcode = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Barcode Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a barcode to test (e.g., 5449000000996 for Coca-Cola)'),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter barcode number',
              ),
              onChanged: (value) => barcode = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (barcode.isNotEmpty) {
                _handleBarcodeScan(barcode);
              }
            },
            child: const Text('Test'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Manual Input',
            onPressed: _showTestBarcodeDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (!_isScanning) return; // Ignore detections when not scanning
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleBarcodeScan(barcode.rawValue!);
                  _toggleScanning(); // Stop scanning after detection
                }
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleScanning,
        icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
        label: Text(_isScanning ? 'Stop' : 'Scan'),
        backgroundColor: _isScanning ? Colors.red : Theme.of(context).primaryColor,
      ),
    );
  }
}