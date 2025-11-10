import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/food_info.dart';
import '../global_keys.dart';
import '../services/user_preferences.dart';
import 'scanned_food_detail_screen.dart';

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

  void _handleBarcodeScan(String barcode) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final foodInfo = await ingredientsAndNutrimentsFromBarcode(barcode);

      // Dismiss loading indicator
      if (!mounted) return;
      Navigator.of(context).pop();

      if (foodInfo == null) {
        // Show error if no product found
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Product Not Found'),
            content: const Text('Unable to find product information. Please try again or scan a different product.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final foodName = foodInfo['food_name'] as String? ?? 'Unknown Product';
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

      // Show warning dialog if allergens are found
      if (matchedAllergens.isNotEmpty) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[200],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 32),
                  const SizedBox(width: 10),
                  const Text(
                    'ALLERGIC',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.warning, color: Colors.red, size: 32),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CONTAINS:\n"${matchedAllergens.join('", "')}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'CONTINUE TO VIEW\nPRODUCT?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'YES',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'NO',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );

        if (shouldContinue != true) {
          return;
        }
      }

      // Navigate to detailed food information screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedFoodDetailScreen(
            foodName: foodName,
            companyName: foodInfo['brand'] as String?,
            ingredients: ingredients,
            nutriments: nutriments,
            allergenTags: allergenTags,
            traces: traces,
            matchedAllergens: matchedAllergens,
            matchedAdditives: matchedAdditives,
            imageUrl: foodInfo['image_url'] as String?,
          ),
        ),
      );
    } catch (e) {
      // Dismiss loading indicator if it's showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: const Text('Unable to connect to the food database. Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
