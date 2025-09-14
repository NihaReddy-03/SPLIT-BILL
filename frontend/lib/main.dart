import 'package:flutter/material.dart';
import 'screens/tutorial_screen.dart';
import 'screens/ocr_screen.dart'; // ✅ Import the OCR widget

void main() {
  runApp(BillSplittingApp());
}

class BillSplittingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Splitting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: TutorialScreen(),  // ✅ Always opens tutorial screen
      debugShowCheckedModeBanner: false,
      routes: {
        '/ocr': (context) => BillOCRScreen(), // ✅ OCR route added
      },
    );
  }
}
