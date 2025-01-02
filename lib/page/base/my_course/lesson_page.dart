import 'dart:ffi';
import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/comment.dart';
import 'package:studysama/models/resource_file.dart';
import 'package:studysama/models/user_course.dart';
import 'package:studysama/page/base/my_course/resource_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
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
  UserCourse? userCourse;
  LessonPage({Key? key, required this.lesson, required this.course, required this.isTutor, this.userCourse}) : super(key: key);

  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> with RouteAware {
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
  List<Comment> comments = [];

  int category = 1; // Default category
  File? selectedFile;
  bool isFileUploadSelected = true; // Declare at class level
  String fileName = "Attach File";

  bool isLoading = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route); // Safe subscription
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this page
    print('Page became active again');

    initializeData(); // Refresh data
  }

  Future<void> initializeData() async {
    await loadUser();
    //fetchUserCourse();
    await fetchResources(); // Simulate fetching resources for the lesson
    isLoading = false;
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
      isLoading = true;
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
        isLoading = false;
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
      isLoading = true;
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
        isLoading = false;
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
      isLoading = true;
    });

    try {
      final data = await apiService.index_resource_lesson(token, widget.lesson.id);

      // Map `ResourceFile` data for quick lookup by `fileId`.
      final resourceFilesMap = {
        for (var file in (data['resource_files'] as List))
          file['id']: ResourceFile.fromJson(file)
      };

      final resourceMap = {
        for (var file in (data['resources'] as List))
          file['id']: Resource.fromJson(file)
      };

      // Combine `Resource` with corresponding `ResourceFile`.
      setState(() {
        resources = (data['resources'] as List)
            .map((json) {
          final resource = Resource.fromJson(json);
          resource.resourceFile = resourceFilesMap[resource.fileId];
          return resource;
        }).toList();

        comments = (data['comments'] as List)
            .map((json) {
          final comment = Comment.fromJson(json);
          comment.resource = resourceMap[comment.resourceId];
          return comment;
        }).toList();


      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
        isLoading = false;
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
        title: Text(
            "Lesson"
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.isTutor)
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: PopupMenuButton<String>(
                icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Colors.black),
                onSelected: (String value) async {
                  switch (value) {
                    case 'Manage Lesson':
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
                      break;
                    case 'Add Resource':
                      _showAddResourceBottomSheet(context);
                      break;
                    case 'Hint':
                      // _showHint();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Manage Lesson',
                      child: Text('Manage Lesson'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Add Resource',
                      child: Text('Add Resource'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Hint',
                      child: Text('Hint'),
                    ),
                  ];
                },
              ),
            ),
        ],
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Text(
                  //   "About",
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     fontFamily: 'Montserrat',
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              buildLessonInfoSection(),
              if(widget.isTutor)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Manage Lesson"),
                  ),
                ),
              const SizedBox(height: 30),

              // Resources Section Header
              const Text(
                "Resources",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              if(isLoading) ...[
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ] else ...[
                if(resources.isNotEmpty)
                  const SizedBox(height: 10),
                ...resources.map((resource) => buildResourceCard(resource)).toList(),
                if(resources.isEmpty)
                  const SizedBox(
                    height: 350, // Minimum height to ensure proper placement
                    child: Center(
                      child: Text(
                        "No resource found.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ]
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {

        Future<File> compressImage(File file) async {
          final targetPath = file.absolute.path.replaceAll(
            file.absolute.path.split('/').last,
            'compressed_${file.absolute.path.split('/').last}',
          );

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 70, // Adjust quality as needed
          );
          return File(compressedFile!.path); // Convert XFile to File
        }

        Future<void> cropAndCompressImage(File imageFile) async {
          final croppedImage = await ImageCropper().cropImage(
            sourcePath: imageFile.path,
            // aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
            compressFormat: ImageCompressFormat.jpg,
            compressQuality: 100,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: AppColors.primary,
                toolbarWidgetColor: Colors.white,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: 'Crop Image',
              ),
            ],
          );

          if (croppedImage != null) {
            final compressedImage = await compressImage(File(croppedImage.path));
            setState(() {
              selectedFile = compressedImage;
              fileName = selectedFile!.path.split('/').last;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Image cropping failed!")),
            );
          }
        }

        Future<void> pickFile() async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'png', 'jpg', 'jpeg'
            ],
          );

          if (result != null) {
            if (result.files.single.size <= 5 * 1024 * 1024) {
              final fileExtension = result.files.single.extension;
              if (['png', 'jpg', 'jpeg'].contains(fileExtension)) {
                // If the file is an image, call the pickImage function
                await cropAndCompressImage(File(result.files.single.path!));
              } else {
                // Otherwise, handle the file as usual
                selectedFile = File(result.files.single.path!);
                setState(() {
                  fileName = result.files.single.name; // Update with selected file name
                });
              }
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
                        decoration: InputDecoration(
                          labelText : 'Resource Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      DropdownButtonFormField<int>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'It is note? Or an assignment?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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
                          decoration: InputDecoration(
                            labelText: 'Link',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
            );
          },
        );
      },
    );
  }

  // Build Lesson Info Section
  Widget buildLessonInfoSection() {
    return Column(
      children: [
        // First Card: Title and Description
        Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                  // Divider(
                  //   height: 30,
                  //   color: Colors.black,
                  //   thickness: 1,
                  // ),
                  const SizedBox(height: 30),
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.lesson.description ?? "No description available.",
                    style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Second Card: Learning Outcome
        Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Learning Outcome:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }

  // Build Resource Card
  Widget buildResourceCard(Resource resource) {
    Color cardColor;
    String resourceType;

    // Generate a thumbnail for the resource
    Widget thumbnail = Container(); // Default to no thumbnail
    const double thumbnailHeight = 150.0; // Fixed height for all thumbnails
    const double thumbnailWidth = double.infinity; // Full width

    int commentCount = 0;
    for(int i = 0; i < comments.length; i++) {
      if(comments[i].resourceId == resource.id && comments[i].status != 0)
        commentCount++;
    }

    if (resource.link != null) {
      if (isYouTubeLink(resource.link!)) {
        // YouTube video thumbnail
        String videoId = extractYouTubeVideoId(resource.link!);
        String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        thumbnail = ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: thumbnailHeight,
          ),
        );
      } else {
        // Generic link preview
        thumbnail = ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: AnyLinkPreview(
            link: resource.link!,
            displayDirection: UIDirection.uiDirectionHorizontal,
            borderRadius: 0,
            showMultimedia: true,
            backgroundColor: Colors.grey[200],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResourcePage(
                    resource: resource,
                    isTutor: widget.isTutor,
                    course: widget.course,
                    lesson: widget.lesson,
                    userCourse: widget.userCourse,
                    onDelete: () {
                      // Logic to delete the resource
                      print("Resource deleted: ${resource.name}");
                    },
                  ),
                ),
              );
            },
            placeholderWidget: const SizedBox(
              height: thumbnailHeight,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: Container(
              height: thumbnailHeight,
              color: Colors.grey[300],
              child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.link, // Use a file icon based on the file type
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Preview not available",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  )
              ),
            ),
          ),
        );
      }
    } else if (resource.resourceFile != null) {
      // File preview using open_file
      thumbnail = ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResourcePage(
                  course: widget.course,
                  lesson: widget.lesson,
                  resource: resource,
                  isTutor: widget.isTutor,
                  onDelete: () {
                    // Logic to delete the resource
                    print("Resource deleted: ${resource.name}");
                  },
                ),
              ),
            );
          },
          child: Container(
            height: thumbnailHeight,
            width: double.infinity,
            color: Colors.grey[300], // Background color for the file preview
            child: Center(
              child: resource.resourceFile != null && ['jpg', 'jpeg', 'png'].contains(resource.resourceFile!.type.toLowerCase())
              ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: NetworkImage(domainURL + '/storage/${resource.resourceFile!.name}'),
                    fit: BoxFit.cover,
                  ),
                ),
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    getFileIcon(resource.resourceFile!.type), // Use a file icon based on the file type
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Preview not available",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Determine card color and resource type based on category
    switch (resource.category) {
      case 1:
        cardColor = Colors.blue[300]!;
        resourceType = "Note (Lecture)";
        break;
      case 2:
        cardColor = Colors.red[300]!;
        resourceType = "Assignment (Lab)";
        break;
      default:
        cardColor = Colors.grey[300]!;
        resourceType = "Other";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourcePage(
              course: widget.course,
              lesson: widget.lesson,
              resource: resource,
              isTutor: widget.isTutor,
              onDelete: () {
                // Logic to delete the resource
                print("Resource deleted: ${resource.name}");
              },
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the generated thumbnail if available
            if (thumbnail != null) thumbnail,
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      child: Text(
                        resourceType,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // if (resource.resourceFile != null) ...[
                    //   Row(
                    //     children: [
                    //       const Icon(
                    //         FontAwesomeIcons.download,
                    //         size: 20,
                    //         color: Colors.black,
                    //       ),
                    //       const SizedBox(width: 4),
                    //       Text(
                    //         "${resource.resourceFile!.totalDownload}",
                    //         style: const TextStyle(fontSize: 12, color: Colors.black,),
                    //       ),
                    //     ],
                    //   ),
                    //   const SizedBox(width: 16),
                    // ],
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.comment,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4),
                        Text(
                          commentCount.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.black,),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      resource.link != null
                          ? FontAwesomeIcons.link
                          : getFileIcon(resource.resourceFile?.type ?? ""),
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to determine file type icon
  IconData getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return FontAwesomeIcons.fileImage; // Assuming you have an icon for images
      default:
        return FontAwesomeIcons.file;
    }
  }

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
