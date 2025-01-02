import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/utils/colors.dart';

import '../../../models/user.dart';
import '../../../services/api_service.dart';

class CreateCoursePage extends StatefulWidget {
  final VoidCallback onCourseCreated; // Callback to refresh courses
  const CreateCoursePage({required this.onCourseCreated, Key? key}) : super(key: key);

  @override
  _CreateCoursePageState createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  User? user;
  int user_id = 0;
  String token = "";

  File? selectedImage; // Stores the selected or cropped image
  final ImagePicker _picker = ImagePicker();

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final userString = prefs.getString('user');
      // if (userString != null) {
      //   Map<String, dynamic> userMap = jsonDecode(userString);
      //   user = User.fromJson(userMap);
      //   user_id = user!.id;
      // }

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

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    String name = nameController.text.trim();
    String desc = descriptionController.text.trim();

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.course_store(token, name, desc, selectedImage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course "$name" created successfully with description: "$desc"',
          ),
        ),
      );
      widget.onCourseCreated(); // Notify parent to refresh
      Navigator.pop(context); // Navigate back to the previous page

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course creation failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
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
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Create Course',
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
        child: Form(
          key: _formKey, // Associate the form key with the Form widget
          child: SingleChildScrollView(
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
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[300],
                          image: selectedImage != null
                              ? DecorationImage(
                            image: FileImage(selectedImage!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: selectedImage == null
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.image,
                                color: Colors.black54,
                                size: 50,
                              ),
                              Text('(Optional)')
                            ]
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
                            backgroundColor: AppColors.secondary,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: 'Enter course name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter course name';
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: 'Enter course description',
                  ),
                  maxLines: 3, // Allows for a multi-line description
                ),
                const SizedBox(height: 16),
                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createCourse,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary
                    ),
                    child: const Text(
                      'Create Course',
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
        ),
      ),
    );
  }
}
