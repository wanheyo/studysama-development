import 'package:flutter/material.dart';
import '../../../models/lesson.dart';
import '../../../models/resource.dart'; // The shared Resource model

class LessonPage extends StatefulWidget {
  final Lesson lesson;

  const LessonPage({Key? key, required this.lesson}) : super(key: key);

  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final List<Resource> resources = []; // Replace with fetched resources

  @override
  void initState() {
    super.initState();
    fetchResources(); // Simulate fetching resources for the lesson
  }

  void fetchResources() {
    // Mock resources for demonstration purposes
    setState(() {
      resources.addAll([
        Resource(
          id: 1,
          lessonId: widget.lesson.id!,
          name: 'Intro Video',
          description: 'A brief introduction to the topic.',
          link: 'https://youtube.com/some-video',
          category: 1, // YouTube category
          totalVisit: 500,
          status: 1,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          updatedAt: DateTime.now(),
          fileId: null,
        ),
        Resource(
          id: 2,
          lessonId: widget.lesson.id!,
          name: 'Lecture Notes',
          description: 'Detailed lecture notes.',
          link: null,
          category: 2, // File category
          totalVisit: 150,
          status: 1,
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          updatedAt: DateTime.now(),
          fileId: 101,
        ),
        Resource(
          id: 3,
          lessonId: widget.lesson.id!,
          name: 'Lab Instructions',
          description: 'Guidelines for the lab activity.',
          link: null,
          category: 2, // File category
          totalVisit: 45,
          status: 1,
          createdAt: DateTime.now().subtract(Duration(days: 12)),
          updatedAt: DateTime.now().subtract(Duration(days: 3)),
          fileId: 102,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson Info Section
              buildLessonInfoSection(),

              const SizedBox(height: 20),

              // Resources Section
              const Text(
                "Resources",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 10),

              ...resources.map((resource) => buildResourceCard(resource)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Build Lesson Info Section
  Widget buildLessonInfoSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lesson.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Description:",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.lesson.description ?? "No description available.",
                style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 30),
              const Text(
                "Learning Outcome :",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.lesson.learnOutcome ?? "No learning outcome stated.",
                style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Resource Card
  Widget buildResourceCard(Resource resource) {
    // Determine type based on category
    IconData iconData;
    Color cardColor;
    String resourceType;

    switch (resource.category) {
      case 1: // YouTube
        iconData = Icons.video_library;
        cardColor = Colors.red[100]!;
        resourceType = "YouTube Video";
        break;
      case 2: // File
        iconData = Icons.insert_drive_file;
        cardColor = Colors.blue[100]!;
        resourceType = "File Resource";
        break;
      default:
        iconData = Icons.help_outline;
        cardColor = Colors.grey[100]!;
        resourceType = "Other";
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(iconData, size: 40, color: Colors.black54),
        title: Text(
          resource.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            if (resource.description != null) Text("Description: ${resource.description}"),
            Text("Created: ${resource.createdAt?.toLocal()}"),
            Text("Updated: ${resource.updatedAt?.toLocal()}"),
            Text("Category: $resourceType"),
            if (resource.link != null) Text("Link: ${resource.link}"),
            if (resource.fileId != null)
              Text("File ID: ${resource.fileId} (Visits: ${resource.totalVisit})"),
          ],
        ),
        onTap: () {
          // Handle resource interaction
          if (resource.link != null) {
            // Open the YouTube link
          } else if (resource.fileId != null) {
            // Open the file viewer
          }
        },
      ),
    );
  }
}
