import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoScreen extends StatelessWidget {
  final String courseId;

  VideoScreen(this.courseId);

  @override
  Widget build(BuildContext context) {
    CollectionReference videoCollection = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('videos');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: videoCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching videos'));
          }
          if (snapshot.hasData) {
            final videos = snapshot.data!.docs;
            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(video['title']),
                  onTap: () {
                    // Implement video playback logic here
                  },
                );
              },
            );
          }
          return Center(child: Text('No videos available'));
        },
      ),
    );
  }
}
