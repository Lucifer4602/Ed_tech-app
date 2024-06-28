import 'package:ed_tech/admin_screens/CourseUploadScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to course upload screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CourseUploadScreen()),
            );
          },
          child: Text('Upload New Course'),
        ),
      ),
    );
  }
}
