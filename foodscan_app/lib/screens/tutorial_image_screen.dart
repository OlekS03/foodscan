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

Profile Page:  This page is where you can add your known allergens, and any unwanted additives you are trying to avoid.  These should only be ingredients you are trying to avoid completely since any foods containing them will be flagged as unsafe. Here you can also view the licenses and change from light mode to dark mode. \n

Scan Page:  The main goal of the scan page is to scan your food's barcodes to view the extended details of that product's nutrition facts.  You will also be alerted if that food contains any item from your list of additives or allergens.  You can either scan by pressing the start scanning button while the barcode is in frame, or by entering the UPC code (The numbers under the barcode) by clicking on the button in the top right. \n

Food List Page:  After you save any scanned foods you can find them here, initially in order of when you scanned them.  There is also filtering options located at the top right that allow you to filter out or reorder all the items in your food list.  You can also review the items extended details by clicking on the arrow next to its name, or delete it from your list by clicking the trash bin.
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
