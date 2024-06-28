import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatelessWidget {
  final String courseId;

  NotesScreen(this.courseId);

  @override
  Widget build(BuildContext context) {
    CollectionReference notesCollection = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('notes');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: notesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching notes'));
          }
          if (snapshot.hasData) {
            final notes = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(note['title']),
                  onTap: () {
                    // Implement notes view logic here
                  },
                );
              },
            );
          }
          return Center(child: Text('No notes available'));
        },
      ),
    );
  }
}
