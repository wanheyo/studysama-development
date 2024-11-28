import 'dart:ffi';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/resource_file.dart';
import 'package:url_launcher/url_launcher.dart';
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
  //final List<Resource> resources = []; // Replace with fetched resources

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;
  String token = "";
  bool isTutor = false;
  bool isStudent = false;

  List<Resource> resources = [];
  List<ResourceFile> resource_files = [];

  int category = 1; // Default category
  File? selectedFile;
  bool isFileUploadSelected = true; // Declare at class level
  String fileName = "Attach File";


  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    nameController.dispose();
    descController.dispose();
    linkController.dispose();
    super.dispose();
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
      await apiService.resource_store(token, name, desc, category, link, widget.lesson.id, "", "", selectedFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Resources "$name" created successfully',
          ),
        ),
      );
      print("Resources created successfully");
      initializeData();
      //widget.onCourseCreated(); // Notify parent to refresh
      //Navigator.pop(context); // Navigate back to the previous page

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resource creation failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
        Navigator.pop(context);

        nameController.clear();
        descController.clear();
        linkController.clear();
        setState(() {
          selectedFile = null;
          fileName = "Attach File";
          isFileUploadSelected = true;
          category = 1; // Reset to default category
        });
      });
    }
  }

  Future<void> fetchResources() async {
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      final data = await apiService.index_resource_lesson(token, widget.lesson.id);

      // Map `ResourceFile` data for quick lookup by `fileId`.
      final resourceFilesMap = {
        for (var file in (data['resource_files'] as List))
          file['id']: ResourceFile.fromJson(file)
      };

      // Combine `Resource` with corresponding `ResourceFile`.
      setState(() {
        resources = (data['resources'] as List)
            .map((json) {
          final resource = Resource.fromJson(json);
          resource.resourceFile = resourceFilesMap[resource.fileId];
          return resource;
        })
            .toList();
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


  bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final urlRegex = RegExp(
      r'^(https?://)?'  // Optional protocol
      r'(([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}'  // Domain name
      r'(\.[a-z]{2,})?'  // Optional top-level domain
      r'(:\d+)?'  // Optional port
      r'(/[-a-z\d%_.~+]*)*'  // Path
      r'(\?[;&a-z\d%_.~+=-]*)?'  // Query string
      r'(#[-a-z\d_]*)?$',  // Fragment locator
      caseSensitive: false,
    );

    return urlRegex.hasMatch(url);
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
        Future<void> pickFile() async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx',
              'png', 'jpg', 'jpeg'
            ],
          );

          if (result != null) {
            if (result.files.single.size <= 5 * 1024 * 1024) {
              selectedFile = File(result.files.single.path!);
              fileName = result.files.single.name; // Update with selected file name
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("File size exceeds the 5MB limit!")),
              );
            }
          }
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: LoaderOverlay(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled, // This prevents automatic validation
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

                        // Modify the Radio buttons to clear fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: isFileUploadSelected,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        isFileUploadSelected = true;
                                        // Clear all fields
                                        nameController.clear();
                                        descController.clear();
                                        linkController.clear();
                                        selectedFile = null;
                                        fileName = "Attach File";
                                        category = 1; // Reset to default category
                                      });
                                    }
                                  },
                                ),
                                const Text("Upload File"),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: isFileUploadSelected,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        isFileUploadSelected = false;
                                        // Clear all fields
                                        nameController.clear();
                                        descController.clear();
                                        linkController.clear();
                                        selectedFile = null;
                                        fileName = "Attach File";
                                        category = 1; // Reset to default category
                                      });
                                    }
                                  },
                                ),
                                const Text("Provide Link"),
                              ],
                            ),
                          ],
                        ),


                        const SizedBox(height: 16.0),

                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText : 'Resource Name',
                            border: OutlineInputBorder(),
                            hintText: 'Example: My Personal Note',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter resource name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
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
                            hintText: 'It is note? Or an assignment?',
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

                        // Conditionally show the file upload button or the link input
                        if (!isFileUploadSelected) ...[
                          TextFormField(
                            controller: linkController,
                            decoration: const InputDecoration(
                              labelText: 'Link',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (!isFileUploadSelected && (value == null || value.isEmpty)) {
                                return 'Please provide a link';
                              }
                              if (!isFileUploadSelected && value != null && !isValidUrl(value)) {
                                return 'Please enter a valid link';
                              }
                              return null;
                            },
                          ),
                        ],

                        // Modify the "Upload File" section
                        if (isFileUploadSelected) ...[
                          TextButton.icon(
                            onPressed: () async {
                              await pickFile();
                              if (selectedFile != null) {
                                // Update UI with file name
                                setState(() {
                                  fileName = selectedFile!.path.split('/').last;
                                });
                              }
                            },
                            icon: const Icon(Icons.attach_file),
                            label: Text(
                              fileName.isNotEmpty ? fileName : "Attach File",
                              style: TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (isFileUploadSelected && selectedFile == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Please select a file to upload',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ],
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Clear all fields before closing
                                nameController.clear();
                                descController.clear();
                                linkController.clear();
                                setState(() {
                                  selectedFile = null;
                                  fileName = "Attach File";
                                  isFileUploadSelected = true;
                                  category = 1; // Reset to default category
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            // Modify the ElevatedButton's onPressed method
                            ElevatedButton(
                              onPressed: () {
                                // Reset selectedFile and fileName if not in file upload mode
                                if (!isFileUploadSelected) {
                                  selectedFile = null;
                                  fileName = "Attach File";
                                }

                                // Validate the form
                                if (_formKey.currentState!.validate()) {
                                  // Additional custom validation based on radio button selection
                                  if (isFileUploadSelected && selectedFile == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please select a file to upload")),
                                    );
                                    return;
                                  }

                                  if (!isFileUploadSelected && (linkController.text.isEmpty || !isValidUrl(linkController.text))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please provide a valid link")),
                                    );
                                    return;
                                  }

                                  // If all validations pass, proceed with creating the resource
                                  _createResource();
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
                ),
              ),
            );
          },
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
    IconData iconData;
    Color cardColor;
    String resourceType;

    switch (resource.category) {
      case 1:
        iconData = FontAwesomeIcons.solidFile;
        cardColor = Colors.blue[100]!;
        resourceType = "Note (Lecture)";
        break;
      case 2:
        iconData = FontAwesomeIcons.filePen;
        cardColor = Colors.red[100]!;
        resourceType = "Assignment (Lab)";
        break;
      default:
        iconData = FontAwesomeIcons.question;
        cardColor = Colors.grey[100]!;
        resourceType = "Other";
    }

    // Determine thumbnail based on link or file
    Widget thumbnail = Icon(iconData, size: 40, color: Colors.black54);
    if (resource.link != null) {
      if (isYouTubeLink(resource.link!)) {
        String videoId = extractYouTubeVideoId(resource.link!);
        String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        thumbnail = Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        );
      }
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: thumbnail,
        ),
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
            if (resource.resourceFile != null) ...[
              Text("File: ${resource.resourceFile!.name}"),
              Text("Type: ${resource.resourceFile!.type}"),
              Text("Downloads: ${resource.resourceFile!.totalDownload}"),
            ],
          ],
        ),
        onTap: () async {
          if (resource.link != null) {
            final Uri uri = Uri.parse(resource.link!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch ${resource.link}';
            }
          } else if (resource.resourceFile != null) {
            final Uri uri = Uri.parse(domainURL + '/storage/${resource.resourceFile!.name}');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch file URL';
            }
          }
        },
      ),
    );
  }

// Utility functions
  bool isYouTubeLink(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  String extractYouTubeVideoId(String url) {
    Uri uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? ''; // Extract 'v' parameter for video ID
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    }
    return '';
  }
}
