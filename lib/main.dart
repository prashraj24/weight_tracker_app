import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:weight_tracker_app/pages/sign_in_page.dart';

// Weight Tracker App | Wealthy Assignment
// By: Prashanth Raj

void main() {
  runApp(MyApp());
  Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SingInPage(),
    );
  }
}
