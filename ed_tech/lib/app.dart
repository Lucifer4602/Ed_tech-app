import 'package:flutter/material.dart';
import 'package:ed_tech/home_screen.dart'; // Replace with your actual screen files

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(), // Replace with your home screen or initial screen
    );
  }
}
