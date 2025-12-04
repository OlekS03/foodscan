import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/food_info.dart';
import '../services/user_preferences.dart';
import 'scanned_food_detail_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isScanning = true;
  final MobileScannerController _controller = MobileScannerController();

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

  void _handleBarcodeScan(String barcode) async {
    try {

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final foodInfo = await ingredientsAndNutrimentsFromBarcode(barcode);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (foodInfo == null) {
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

      final servingQuantityStr = foodInfo['serving_quantity'] as String?;
      final servingQuantity = servingQuantityStr != null ? double.tryParse(servingQuantityStr) : null;

      Map<String, dynamic> servingNutriments = {};

      if (servingQuantity != null && nutriments.isNotEmpty) {
        nutriments.forEach((key, value) {
          if (key.endsWith('_100g') && value is num) {
            final perServingKey = key.replaceFirst('_100g', '_serving');
            servingNutriments[perServingKey] = (value / 100) * servingQuantity;
          } else {
            servingNutriments[key] = value;
          }
        });
      } else {
        servingNutriments = nutriments;
      }

      final matchedAllergens = await UserPreferences.findMatchingAllergens(
        ingredients,
        allergenTags,
        traces,
      );
      final matchedAdditives = await UserPreferences.findMatchingAdditives(
        ingredients,
      );

      if (!mounted) return;

      if (matchedAllergens.isNotEmpty) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final theme = Theme.of(context);
            final isDarkMode = theme.brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    'ALLERGIC',
                    style: TextStyle(
                      color: isDarkMode ? Colors.red[400] : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.warning, color: isDarkMode ? Colors.red[400] : Colors.red, size: 32),
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
                            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.black,
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
                            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.black,
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedFoodDetailScreen(
            foodName: foodName,
            companyName: foodInfo['brand'] as String?,
            ingredients: ingredients,
            nutriments: servingNutriments,
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
    final isDarkMode = theme.brightness == Brightness.dark;

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
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _toggleScanning,
          backgroundColor: _isScanning
            ? Colors.red[600]
            : (/*isDarkMode ? theme.colorScheme.primary :*/ Colors.green[600]),
          foregroundColor: Colors.black,
          elevation: 0,
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isScanning ? Icons.stop_rounded : Icons.qr_code_scanner_rounded,
              size: 24,
            ),
          ),
          label: Text(
            _isScanning ? 'Stop Scanning' : 'Start Scanning',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
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
        _isScanning = false;
        setState(() {});

        break;
      }
    }
  }
}