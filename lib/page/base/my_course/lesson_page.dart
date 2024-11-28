import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/course.dart';
import '../../../models/lesson.dart';
import '../../../models/resource.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import 'manage_lesson_page.dart'; // The shared Resource model

class LessonPage extends StatefulWidget {
  Lesson lesson;
  Course course;
  bool isTutor;
  LessonPage({Key? key, required this.lesson, required this.course, required this.isTutor}) : super(key: key);

  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final List<Resource> resources = []; // Replace with fetched resources

  final ApiService apiService = ApiService();
  String token = "";
  bool isTutor = false;
  bool isStudent = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUser();
    //fetchUserCourse();
    fetchResources(); // Simulate fetching resources for the lesson
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        token = tokenString;
      }

      setState(() {
        // context.loaderOverlay.show();
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        // context.loaderOverlay.hide();
      });
    }
  }

  Future<void> fetchUserCourse() async {
    setState(() {
      context.loaderOverlay.show();
    });

    int course_id = widget.course.id;
    //print("course_id: " + course_id.toString());
    try {
      final data = await apiService.index_user_course(token, course_id);
      setState(() {
        // Extract boolean values from the response
        isTutor = data['is_user_tutor'] ?? false;
        isStudent = data['is_user_student'] ?? false;
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _createResource() async {
    // if (!_formKey.currentState!.validate()) {
    //   return; // Exit if the form is invalid
    // }

    String name = nameController.text.trim();
    String desc = descController.text.trim();
    String link = linkController.text.trim();

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.lesson_store(token, name, widget.course.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesson "$name" created successfully',
          ),
        ),
      );
      print("Lesson successa ");
      //widget.onCourseCreated(); // Notify parent to refresh
      Navigator.pop(context); // Navigate back to the previous page

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lesson creation failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
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
        actions: [
          if (widget.isTutor)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.solidPenToSquare),
                tooltip: 'Manage Lesson',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageLessonPage(
                        lesson: widget.lesson,
                        course: widget.course,
                        onLessonUpdated: (updatedLesson) {
                          setState(() {
                            widget.lesson = updatedLesson; // Update the lesson data
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "About Lesson",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 10),
              buildLessonInfoSection(),
              const SizedBox(height: 20),
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
      floatingActionButton: widget.isTutor
          ? FloatingActionButton(
        onPressed: () => _showAddResourceBottomSheet(context),
        child: const Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary,
        tooltip: 'Add New Resource',
      )
          : null,
    );
  }

  void _showAddResourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        // final TextEditingController nameController = TextEditingController();
        // final TextEditingController descController = TextEditingController();
        // final TextEditingController linkController = TextEditingController();
        int category = 1; // Default category
        File? selectedFile;

        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16.0),
                const Center(
                  child: Text(
                    "Add New Resource",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Resource Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<int>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Note")),
                    DropdownMenuItem(value: 2, child: Text("Assignment")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      category = value;
                    }
                  },
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextButton.icon(
                  onPressed: () async {
                    // Implement file picker logic here
                    // selectedFile = await pickFile();
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Attach File (optional)"),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Validate inputs and add resource logic here
                        String name = nameController.text;
                        String? desc = descController.text.isEmpty
                            ? null
                            : descController.text;
                        String? link = linkController.text.isEmpty
                            ? null
                            : linkController.text;

                        if (name.isNotEmpty) {
                          // Call API to add resource
                          print("Resource added: $name, $desc, $category, $link");
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add Resource"),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
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
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
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
