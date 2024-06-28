import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MCQScreen extends StatelessWidget {
  final String courseId;

  MCQScreen(this.courseId);

  @override
  Widget build(BuildContext context) {
    CollectionReference mcqCollection = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('mcq_questions');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: mcqCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching MCQ questions'));
          }
          if (snapshot.hasData) {
            final mcqQuestions = snapshot.data!.docs;
            return ListView.builder(
              itemCount: mcqQuestions.length,
              itemBuilder: (context, index) {
                final mcqQuestion =
                    mcqQuestions[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(mcqQuestion['question']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(4, (i) {
                      return Text('${i + 1}. ${mcqQuestion['options'][i]}');
                    }),
                  ),
                );
              },
            );
          }
          return Center(child: Text('No MCQ questions available'));
        },
      ),
    );
  }
}
