import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/login_page.dart';
import 'admin_screens/admin_login_page.dart';
import 'home_screen.dart'; // Ensure you have the correct import for your HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/admin': (context) => AdminLoginPage(),
      },
    );
  }
}
