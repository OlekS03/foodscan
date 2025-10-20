import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/food_info.dart';
import '../screens/food_list_screen.dart';
import '../global_keys.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isPaused = false;
  final MobileScannerController _controller = MobileScannerController();
  String? barcodeResult = '';
  bool optOutFlag = false;
  bool hasSeenPreferencePrompt = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadAllergenPrompt(
    BuildContext context,
    String foodName,
    String ingredients,
    Map<String, dynamic> nutriments,
    List<dynamic> foodAllergen,
    List<dynamic> traces,
    bool hasAllergen,
  ) {
    String allergens = foodAllergen.join(' ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allergens Found: $allergens. Include item anyways?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("call to addItemToFoodsList made");
                foodListKey.currentState?.addItemToFoodsList(
                  foodName,
                  ingredients,
                  nutriments,
                  foodAllergen,
                  traces,
                  hasAllergen,
                );
                if (hasSeenPreferencePrompt == false) {
                  _loadAllergenPreference(context);
                }
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _loadAllergenPreference(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Would you like to disable allergen warnings?'),
          content: const Text(
              'You can change this setting later in the user preferences.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  optOutFlag = true;
                  hasSeenPreferencePrompt = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  hasSeenPreferencePrompt = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue == null) continue;

                debugPrint('Barcode found! ${barcode.rawValue}');
                final foodInfo = await ingredientsAndNutrimentsFromBarcode(
                    barcode.rawValue!);

                if (foodInfo != null) {
                  if (!mounted) return;

                  final foodName = foodInfo['food_name'] as String;
                  final ingredients = foodInfo['ingredients'] as String?;
                  final nutriments = foodInfo['nutriments'] as Map<String, dynamic>?;
                  final allergenTags = foodInfo['allergen_tags'] as List<dynamic>?;
                  final traces = foodInfo['traces'] as List<dynamic>?;

                  if (allergenTags != null && allergenTags.isNotEmpty && !optOutFlag) {
                    _loadAllergenPrompt(
                      context,
                      foodName,
                      ingredients ?? 'No ingredients listed',
                      nutriments ?? {},
                      allergenTags,
                      traces ?? [],
                      true,
                    );
                  } else {
                    foodListKey.currentState?.addItemToFoodsList(
                      foodName,
                      ingredients ?? 'No ingredients listed',
                      nutriments ?? {},
                      allergenTags ?? [],
                      traces ?? [],
                      false,
                    );
                  }
                }
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    onPressed: () => setState(() {
                      _isPaused = !_isPaused;
                      _isPaused ? _controller.stop() : _controller.start();
                    }),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.flip_camera_android),
                    onPressed: () => _controller.switchCamera(),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.flash_on),
                    onPressed: () => _controller.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
