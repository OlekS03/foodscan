import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/food_info.dart';
import '../global_keys.dart';
import '../services/user_preferences.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isScanning = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _controller.start();
      } else {
        _controller.stop();
      }
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
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Warning'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (matchedAllergens.isNotEmpty) ...[
                  Text(
                    'Allergens Detected:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: matchedAllergens.map((allergen) => Chip(
                      label: Text(allergen),
                      backgroundColor: theme.colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (matchedAdditives.isNotEmpty) ...[
                  Text(
                    'Additives Found:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: matchedAdditives.map((additive) => Chip(
                      label: Text(additive),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Would you like to add this item to your list?',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Skip',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Anyway'),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
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
            onDetect: _onDetect,
          ),
          if (!_isScanning)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap the scan button to begin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleScanning,
        icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
        label: Text(_isScanning ? 'Stop' : 'Start Scan'),
        backgroundColor: _isScanning ? Colors.red : theme.colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleBarcodeScan(barcode.rawValue!);
        _toggleScanning(); // Stop scanning after successful detection
        break;
      }
    }
  }
}
