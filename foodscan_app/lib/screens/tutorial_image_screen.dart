import 'package:flutter/material.dart';

class TutorialImageScreen extends StatelessWidget {
  const TutorialImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorial"),
      ),

      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
Welcome to the FoodScan Tutorial!

Display text in tutorial screen
          ''',
          style: TextStyle(
            fontSize: 18,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
