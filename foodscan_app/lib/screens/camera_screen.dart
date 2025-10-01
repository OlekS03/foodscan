import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreenUI extends StatefulWidget {
  const CameraScreenUI({super.key});

  @override
  State<CameraScreenUI> createState() => _CameraScreenUIState();
}

class _CameraScreenUIState extends State<CameraScreenUI> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _controller?.dispose();
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

    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

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
            const Text('Camera permission is required'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Transform.scale(
        scale: 1.0,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
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
          ),
        ],
      ),
    );
  }
}
