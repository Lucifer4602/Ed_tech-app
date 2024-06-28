import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
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
            return Center(child: Text('Error fetching courses'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No courses available'));
          }
          final courses = snapshot.data!.docs;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(course['title']),
                subtitle: Text(course['description']),
                leading: course['thumbnail'] != null
                    ? Image.network(course['thumbnail'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseDetailScreen(courseId: courses[index].id),
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
