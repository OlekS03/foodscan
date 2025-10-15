import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/food_info.dart';
import '../screens/food_list_screen.dart';
import '../global_keys.dart';

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
class CameraScreenUI extends StatefulWidget {
  const CameraScreenUI({super.key});

  @override
  State<CameraScreenUI> createState() => _CameraScreenUIState();
  Widget build(BuildContext context) {
    return const MaterialApp(home: BarcodeScannerPage());
  }
}
*/

class _CameraScreenUIState extends State<CameraScreenUI> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isPaused = false;
  final MobileScannerController _controller = MobileScannerController();

  String? barcodeResult = '';

  //will later be replaced with user profile variable
  bool optOutFlag = false;
  //keeps track of if user has been prompted about allergen warning messages
  bool hasSeenPreferencePrompt = false;

  //deconstructor for the camera controller
  @override
  void dispose() {
    _controller?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
    if (_isPermissionGranted) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras found')),
      );
      return;
    }
  /*
      _loadAllergenPrompt:
    The following function loads a popup message when a user scans an item that
    has a known allergen in their profile. The user will be asked if they want to
    add the food item anyways. If so, they will be
  */
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

    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allergens Found: $allergens. Include item anyways?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo captured: ${photo.path}'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  Widget _buildCameraPreview() {
    if (!_isPermissionGranted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Camera permission is required',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
                //add item to list
                print("call to addItemToFoodsList made");
                foodListKey.currentState?.addItemToFoodsList(
                  foodName,
                  ingredients,
                  nutriments,
                  foodAllergen,
                  traces,
                  hasAllergen,
                );
                //if user has not seen warning/warning has not been disabled, load allergen preferences
                if (hasSeenPreferencePrompt == false) {
                  _loadAllergenPreference(context);
                }
              },
              child: Text('Yes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: const Text('Grant Permission'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('No'),
            ),
          ],
        ),
      );
    }
        );
      },
    );
  }

    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
  /*
    _loadAllergenPreference
*/
  void _loadAllergenPreference(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Would you like to stop recieving these warning messages',
          ),
          actions: [
            TextButton(
              onPressed: () {
                optOutFlag = true;
                hasSeenPreferencePrompt = true;
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                hasSeenPreferencePrompt = true;
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Transform.scale(
        scale: 1.0,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
  Future<Map<String, dynamic>?> getFoodInfo(String barcodeResult) async {
    print("ingredientsAndNutrimentsFromBarcode called");
    final productData = await ingredientsAndNutrimentsFromBarcode(
      barcodeResult,
    );
    return productData;
  }

  /*
      respondToBarcodeRetrieval:

    The following function responds to the barcode retrieval in the following steps:
      1. Info about the food item is retrieved through <FUNCTION CALL>
      2. Food item is compared against list of allergens
        - if food contains user-entered allergen and user had not toggled off earning, then send warning message to user
          - if user declines to add food item, add food item to cart
          - if user accepts food item, add food item to cart with red border
            - ask if user wants to stop recieving messages and to add food items without warnings
              - if yes, toggle messaged to not send
              - if no, continue to present pop up message
        - else add item to cart
  */
  Future<void> _respondToBarcodeRetrieval(String result) async {
    print("getFoodInfo called");
    final productData = await getFoodInfo(result);

    final foodName = productData?['food_name'];
    final ingredients = productData?['ingredients'];
    final nutriments = productData?['nutriments'];
    final allergenTags = productData?['allergen_tags'];
    final traces = productData?['traces'] as List<dynamic>? ?? [];
    List allergensFound = [];

    print("Raw food info: ");
    print("foodName: $foodName");
    print("ingredients: $ingredients");
    print("allergenTags");
    for (final allergen in allergenTags) {
      print(allergen);
    }
    print("traces");
    for (final trace in traces) {
      print(trace);
    }
    print("after traces");

    List<String> dummyAllergens = ["eggs", "milk", "soy"];

    //All allergens are iterated through, and if an allergen matches the list, it is added to the concurrent list of allergens
    for (int i = 0; i < allergenTags.length; i++) {
      bool allergenFound = allergenTags.any(
        (dummyAllergens) =>
            (dummyAllergens as String).toLowerCase() ==
            (allergenTags[i] as String).toLowerCase(),
      );
      if (allergenFound) {
        allergensFound.add(allergenTags[i]);
      }
    }

    print("Allergens Found: ");
    for (final allergen in allergensFound) {
      print("$allergen");
    }
    print("list emtpy: ${allergensFound.isNotEmpty} ");

    //if an allergen is found, we prompt the user if it should still be included.
    if (allergensFound.isNotEmpty == true) {
      if (optOutFlag == false) {
        print('DEBUG: foodListKey.currentState = ${foodListKey.currentState}');
        _loadAllergenPrompt(
          context,
          foodName,
          ingredients,
          nutriments,
          allergenTags,
          traces,
          true,
        );
      } else {
        // add the item to the list with the contains listed allergen set to null
        print('DEBUG: foodListKey.currentState = ${foodListKey.currentState}');
        foodListKey.currentState?.addItemToFoodsList(
          foodName,
          ingredients,
          nutriments,
          allergenTags,
          traces,
          true,
        );
      }
    } else {
      //add the item to the list with
      print("adding item to food list, has no allergen");
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
    return Scaffold(
      appBar: AppBar(title: const Text("Barcode Scanner")),
      body: Stack(
        children: [
          Center(
          MobileScanner(
            onDetect: (capture) async {
              if (_isPaused) {
                return;
              }
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                print("Barcode found");
                for (final barcode in barcodes) {
                  String? upcNumber = barcode.rawValue;
                  if (upcNumber != null) {
                    //print("upc number: $upcNumber");
                    setState(() {
                      barcodeResult = barcode.rawValue;
                    });
                  } else {
                    //print("Barcode has no raw value");
                  }
                }
                if (barcodeResult != null && barcodeResult!.isNotEmpty) {
                  print(
                    "respondToBarcodeRetrieval called with: $barcodeResult",
                  );
                  _respondToBarcodeRetrieval(barcodeResult!);
                  //Pause scanning for 3 seconds
                  setState(() => _isPaused = true);
                  await _controller.stop();
                  await Future.delayed(const Duration(seconds: 3));
                  await _controller.start();
                  setState(() => _isPaused = false);
                } else {
                  //print("No valid barcode result.");
                }
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: isDarkMode ? Colors.white24 : Colors.black26,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildCameraPreview(),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isCameraInitialized ? _takePhoto : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.teal : Colors.cyanAccent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(32),
                  elevation: 4,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement text entry
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.teal : Colors.cyanAccent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  elevation: 4,
                ),
                child: Icon(
                  Icons.edit,
                  size: 24,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Text(
                barcodeResult ?? "Scan a code",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
