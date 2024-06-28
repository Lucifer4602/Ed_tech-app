import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CourseUploadScreen extends StatefulWidget {
  @override
  _CourseUploadScreenState createState() => _CourseUploadScreenState();
}

class _CourseUploadScreenState extends State<CourseUploadScreen> {
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescriptionController =
      TextEditingController();
  final List<Section> _sections = [];
  PlatformFile? _thumbnailImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload New Course'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _courseTitleController,
              decoration: InputDecoration(labelText: 'Course Title'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _courseDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Course Description'),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _pickThumbnailImage,
              child: Text('Select Thumbnail Image'),
            ),
            _thumbnailImage != null
                ? Text('Thumbnail selected: ${_thumbnailImage!.name}')
                : Text('No Thumbnail selected'),
            SizedBox(height: 24.0),
            _buildSections(),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                _uploadCourse();
              },
              child: Text('Upload Course'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSections() {
    return Column(
      children: [
        for (int i = 0; i < _sections.length; i++) _buildSection(i),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _sections.add(Section());
            });
          },
          child: Text('Add Section'),
        ),
      ],
    );
  }

  Widget _buildSection(int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Section ${sectionIndex + 1}',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _sections[sectionIndex].subsections.add(Subsection());
            });
          },
          child: Text('Add Subsection'),
        ),
        for (int i = 0; i < _sections[sectionIndex].subsections.length; i++)
          _buildSubsection(sectionIndex, i),
      ],
    );
  }

  Widget _buildSubsection(int sectionIndex, int subsectionIndex) {
    final subsection = _sections[sectionIndex].subsections[subsectionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subsection ${subsectionIndex + 1}',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () => _pickVideoFile(sectionIndex, subsectionIndex),
          child: Text('Select Video'),
        ),
        subsection.videoFile != null
            ? Text('Video selected: ${subsection.videoFile!.name}')
            : Text('No Video selected'),
        ElevatedButton(
          onPressed: () => _pickPDFFile(sectionIndex, subsectionIndex),
          child: Text('Select Note PDF'),
        ),
        subsection.noteFile != null
            ? Text('PDF selected: ${subsection.noteFile!.name}')
            : Text('No PDF selected'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              subsection.mcqs.add(MCQ());
            });
          },
          child: Text('Add MCQ'),
        ),
        for (int i = 0; i < subsection.mcqs.length; i++)
          _buildMCQField(subsection.mcqs[i]),
      ],
    );
  }

  Widget _buildMCQField(MCQ mcq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: mcq.questionController,
          decoration: InputDecoration(labelText: 'MCQ Question'),
        ),
        TextField(
          controller: mcq.option1Controller,
          decoration: InputDecoration(labelText: 'Option 1'),
        ),
        TextField(
          controller: mcq.option2Controller,
          decoration: InputDecoration(labelText: 'Option 2'),
        ),
        TextField(
          controller: mcq.option3Controller,
          decoration: InputDecoration(labelText: 'Option 3'),
        ),
        TextField(
          controller: mcq.option4Controller,
          decoration: InputDecoration(labelText: 'Option 4'),
        ),
        TextField(
          controller: mcq.correctOptionController,
          decoration: InputDecoration(labelText: 'Correct Option (1-4)'),
        ),
      ],
    );
  }

  void _pickThumbnailImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _thumbnailImage = result.files.first;
      });
    }
  }

  void _pickVideoFile(int sectionIndex, int subsectionIndex) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() {
        _sections[sectionIndex].subsections[subsectionIndex].videoFile =
            result.files.first;
      });
    }
  }

  void _pickPDFFile(int sectionIndex, int subsectionIndex) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _sections[sectionIndex].subsections[subsectionIndex].noteFile =
            result.files.first;
      });
    }
  }

  Future<void> _uploadCourse() async {
    String title = _courseTitleController.text.trim();
    String description = _courseDescriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty && _thumbnailImage != null) {
      // Upload thumbnail image
      String thumbnailUrl = await _uploadFile(_thumbnailImage!);

      CollectionReference courses =
          FirebaseFirestore.instance.collection('courses');

      List<Map<String, dynamic>> sections =
          await Future.wait(_sections.map((section) async {
        List<Map<String, dynamic>> subsections =
            await Future.wait(section.subsections.map((subsection) async {
          String videoUrl = await _uploadFile(subsection.videoFile!);
          String noteUrl = await _uploadFile(subsection.noteFile!);

          return {
            'video': videoUrl,
            'note': noteUrl,
            'mcqs': subsection.mcqs.map((mcq) {
              return {
                'question': mcq.questionController.text.trim(),
                'options': [
                  mcq.option1Controller.text.trim(),
                  mcq.option2Controller.text.trim(),
                  mcq.option3Controller.text.trim(),
                  mcq.option4Controller.text.trim(),
                ],
                'correctOption':
                    int.parse(mcq.correctOptionController.text.trim()) -
                        1, // Zero-based index
              };
            }).toList(),
          };
        }).toList());

        return {
          'subsections': subsections,
        };
      }).toList());

      courses.add({
        'title': title,
        'description': description,
        'thumbnail': thumbnailUrl,
        'sections': sections,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course uploaded successfully')),
        );
        // Clear fields
        _courseTitleController.clear();
        _courseDescriptionController.clear();
        setState(() {
          _sections.clear();
          _thumbnailImage = null;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload course: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all required fields')),
      );
    }
  }

  Future<String> _uploadFile(PlatformFile file) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('uploads/${file.name}');
    final uploadTask = storageRef.putData(file.bytes!);
    final taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}

class Section {
  List<Subsection> subsections = [];
}

class Subsection {
  final TextEditingController videoController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  PlatformFile? videoFile;
  PlatformFile? noteFile;
  final List<MCQ> mcqs = [];
}

class MCQ {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();
  final TextEditingController correctOptionController = TextEditingController();
}
