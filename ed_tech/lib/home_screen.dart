import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_tech/courses_screens/course_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: coursesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching courses: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No courses available'));
          }
          final courses = snapshot.data!.docs;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final courseId = course.id;
              final courseData = course.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(courseData['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseDetailScreen(courseId: courseId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
