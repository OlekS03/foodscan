import 'package:flutter/material.dart';

class TutorialImageScreen extends StatelessWidget {
  const TutorialImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutorial")),

      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.asset(
            'assets/tutorial/tutorial.png',  // <-- your PNG here
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
