import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  CourseDetailScreen({required this.courseId});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late DocumentReference courseDoc;
  late Future<DocumentSnapshot> courseFuture;

  @override
  void initState() {
    super.initState();
    courseDoc =
        FirebaseFirestore.instance.collection('courses').doc(widget.courseId);
    courseFuture = courseDoc.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching course details'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Course not found'));
          }
          final course = snapshot.data!.data() as Map<String, dynamic>;
          final sections = course['sections'] as List<dynamic>;
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              if (course['thumbnail'] != null)
                Image.network(course['thumbnail']),
              Text(course['title'],
                  style:
                      TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.0),
              Text(course['description']),
              SizedBox(height: 24.0),
              ...sections.map((section) => _buildSection(section)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final subsections = section['subsections'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Section',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ...subsections
            .map((subsection) => _buildSubsection(subsection))
            .toList(),
      ],
    );
  }

  Widget _buildSubsection(Map<String, dynamic> subsection) {
    final mcqs = subsection['mcqs'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subsection',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.0),
        _buildVideoPlayer(subsection['video']),
        SizedBox(height: 12.0),
        _buildPDFViewer(subsection['note']),
        SizedBox(height: 24.0),
        ...mcqs.map((mcq) => _buildMCQ(mcq)).toList(),
      ],
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayerWidget(videoUrl: videoUrl),
    );
  }

  Widget _buildPDFViewer(String pdfUrl) {
    return Container(
      height: 400,
      child: SfPdfViewer.network(pdfUrl),
    );
  }

  Widget _buildMCQ(Map<String, dynamic> mcq) {
    final options = mcq['options'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mcq['question'], style: TextStyle(fontSize: 16.0)),
        ...options.map((option) => Text('- $option')).toList(),
        SizedBox(height: 12.0),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
