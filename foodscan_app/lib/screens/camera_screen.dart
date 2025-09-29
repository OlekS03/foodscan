import 'package:flutter/material.dart';

class CameraScreenUI extends StatelessWidget {
  const CameraScreenUI({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F2FD),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black26, width: 2),
              ),
              child: const Center(
                child: Text('Camera Preview', style: TextStyle(color: Colors.black38)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(32),
                  elevation: 4,
                ),
                child: const Text('Take photo', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  elevation: 4,
                ),
                child: const Text('Enter as text', style: TextStyle(color: Colors.black, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
