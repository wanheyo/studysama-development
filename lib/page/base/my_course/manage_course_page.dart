import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class ManageCoursePage extends StatefulWidget {
  final Course course;
  final Function(Course updatedCourse) onCourseUpdated;
  const ManageCoursePage({required this.course, required this.onCourseUpdated, Key? key}) : super(key: key);

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController _deleteConfirmationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;

  User? user;
  int user_id = 0;
  String token = "";
  int? selectedStatus;

  File? selectedImage; // Stores the selected or cropped image
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    String name = nameController.text.trim();
    String desc = descriptionController.text.trim();
    int status = selectedStatus ?? 1;

    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API and get the updated course data
      final updatedData = await apiService.course_update(token, widget.course.id, name, desc, status, selectedImage);

      // Show success message with the updated course data
      final updatedCourse = Course.fromJson(updatedData['course']); // Convert response to Course model
      // Notify the parent page with the updated course
      widget.onCourseUpdated(updatedCourse);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "${updatedCourse.name}" updated successfully!'),
        ),
      );


      Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course update failed: $errorMsg')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _deleteCourse() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    String name = nameController.text.trim();
    String desc = descriptionController.text.trim();
    int status = 0;

    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API and get the updated course data
      final updatedData = await apiService.course_update(token, widget.course.id, name, desc, status, selectedImage);

      // Show success message with the updated course data
      final updatedCourse = Course.fromJson(updatedData['course']); // Convert response to Course model
      // Notify the parent page with the updated course
      widget.onCourseUpdated(updatedCourse);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "${updatedCourse.name}" deleted successfully!'),
        ),
      );
      Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course update failed: $errorMsg')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the dialog size wrap its content
            children: [
              const Text('Are you sure you want to delete this course? This action cannot be undone.'),
              const SizedBox(height: 16),
              TextField(
                controller: _deleteConfirmationController,
                decoration: InputDecoration(
                  labelText: 'Type course name to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Check if the input matches the course name
                if (_deleteConfirmationController.text.trim() == widget.course.name) {
                  Navigator.of(context).pop(); // Close the dialog
                  _deleteCourse(); // Call the delete course function
                } else {
                  // Show an error message if the names do not match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Course name does not match. Please try again.'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileSize = await pickedFile.length();
      if (fileSize <= 5 * 1024 * 1024) {
        cropImage(File(pickedFile.path));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image size exceeds 5MB!")),
        );
      }
    }
  }

  Future<void> cropImage(File? imageFile) async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected for cropping!")),
      );
      return;
    }

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
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
        selectedImage = compressedImage;
      });
    }
  }

  Future<File> compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 70, // Adjust quality as needed
    );
    return File(compressedFile!.path); // Convert XFile to File
  }

  @override
  void initState() {
    super.initState();
    loadUser();

    nameController.text = widget.course.name;
    descriptionController.text = widget.course.desc ?? '';
    selectedStatus = widget.course.status;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    nameController.dispose();
    descriptionController.dispose();
    _deleteConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Manage Course',
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LoaderOverlay(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.grey[300],
                                  image: selectedImage != null
                                      ? DecorationImage(
                                    image: FileImage(selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                      : widget.course.image != null
                                      ? DecorationImage(
                                    image: NetworkImage(domainURL + '/storage/${widget.course.image!}',),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: (widget.course.image == null && selectedImage == null)
                                    ? Center(
                                  child: Icon(
                                    FontAwesomeIcons.image,
                                    color: Colors.black54,
                                    size: 50,
                                  ),
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: pickImage,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppColors.primary,
                                    child: Icon(FontAwesomeIcons.camera, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Course Name Field
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Course Name',
                            border: OutlineInputBorder(),
                            hintText: 'Enter new course name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Course name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Description Field
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            border: OutlineInputBorder(),
                            hintText: widget.course.desc == null ? 'Enter new course description' : null,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Course Status',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<int>(
                              value: 1, // Public
                              child: Text('Public'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2, // Private
                              child: Text('Private'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        if (selectedStatus == 1)
                          Text(
                            "Public will make your course can be seen by everyone.",
                            style: TextStyle(color: Colors.black54),
                          )
                        else if (selectedStatus == 2)
                          Text(
                            "Private will make your course hidden from everyone. Only you will be able to see it.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Update Button
                  ElevatedButton(
                    onPressed: _updateCourse,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Center(
                      child: const Text(
                        'Update Course',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete Course Button
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(); // Show confirmation dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Center(
                      child: const Text(
                        'Delete Course',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
