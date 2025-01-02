import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:studysama/models/resource.dart';

import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class ManageResourcePage extends StatefulWidget {
  final Resource resource;

  const ManageResourcePage ({required this.resource, Key? key}) : super(key: key);

  @override
  _ManageResourcePageState createState() => _ManageResourcePageState();
}

class _ManageResourcePageState extends State<ManageResourcePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  final TextEditingController _deleteConfirmationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  String token = "";
  bool isFileUploadSelected = true;
  File? selectedFile;
  String fileName = "Attach File";
  int category = 1; // Default category

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



  bool isValidUrl(String url) {
    // Add your URL validation logic here
    return Uri.tryParse(url)?.hasScheme ?? false;
  }

  Future<void> _updateResource() async {
    String name = nameController.text.trim();
    String desc = descController.text.trim();
    String link = linkController.text.trim();

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    int status = 1;
    int isUpdateFile = 0;
    if(isFileUploadSelected)
      isUpdateFile = 1;

    try {
      // Call the API
      await apiService.resource_update(token, isUpdateFile, name, desc, category, link, widget.resource.id, "", "", widget.resource.resourceFile?.id, selectedFile, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Resources "$name" updated successfully',
          ),
        ),
      );
      print("Resources created successfully");
      //initializeData();
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

    Navigator.pop(context); // Close the page after creating the resource
  }

  Future<void> _deleteResource() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    String name = nameController.text.trim();
    String desc = descController.text.trim();
    String link = linkController.text.trim();
    int status = 0;
    selectedFile = null;

    setState(() {
      context.loaderOverlay.show();
    });

    int isUpdateFile = 0; //to delete, no need to upload/update file

    try {
      // Call the API and get the updated course data
      final updatedData = await apiService.resource_update(token, isUpdateFile, name, desc, category, link, widget.resource.id, "", "", widget.resource.resourceFile?.id, selectedFile, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resource deleted successfully!'),
        ),
      );
      Navigator.of(context)..pop()..pop();
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resource update failed: $errorMsg')),
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
              const Text('Are you sure you want to delete this resource? This action cannot be undone.'),
              const SizedBox(height: 16),
              TextField(
                controller: _deleteConfirmationController,
                decoration: InputDecoration(
                  labelText: 'Type resource name to confirm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Check if the input matches the course name
                if (_deleteConfirmationController.text.trim() == widget.resource.name) {
                  Navigator.of(context).pop(); // Close the dialog
                  _deleteResource(); // Call the delete lesson function
                } else {
                  // Show an error message if the names do not match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Resource name does not match. Please try again.'),
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

  @override
  void initState() {
    super.initState();
    loadUser();

    isFileUploadSelected = widget.resource.resourceFile != null;

    nameController.text = widget.resource.name;
    descController.text = widget.resource.description ?? '';
    category = widget.resource.category;
    linkController.text = widget.resource.link ?? '';
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Resource"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.background,
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
                            const SizedBox(height: 16.0),
                            // Radio buttons for file upload or link
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
                                            // nameController.clear();
                                            // descController.clear();
                                            // linkController.clear();
                                            selectedFile = null;
                                            fileName = "Attach File";
                                            // category = 1; // Reset to default category
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
                                            // nameController.clear();
                                            // descController.clear();
                                            // linkController.clear();
                                            selectedFile = null;
                                            fileName = "Attach File";
                                            // category = 1; // Reset to default category
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
                                labelText: 'Resource Name',
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
                                hintText: ' It is note? Or an assignment?',
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
                                  setState(() {
                                    category = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 10.0),
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
                            if (isFileUploadSelected) ...[
                              TextButton.icon(
                                onPressed: () async {
                                  await pickFile();
                                },
                                icon: const Icon(Icons.attach_file),
                                label: Text(
                                  fileName.isNotEmpty ? fileName : "Attach File",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              if (selectedFile == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Please select a file to upload',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                            // const SizedBox(height: 16.0),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     TextButton(
                            //       onPressed: () {
                            //         Navigator.pop(context); // Close the page without saving
                            //       },
                            //       child: const Text("Cancel"),
                            //     ),
                            //     ElevatedButton(
                            //       onPressed: () {
                            //         if (_formKey.currentState!.validate()) {
                            //           if (isFileUploadSelected && selectedFile == null) {
                            //             ScaffoldMessenger.of(context).showSnackBar(
                            //               const SnackBar(content: Text("Please select a file to upload")),
                            //             );
                            //             return;
                            //           }
                            //           if (!isFileUploadSelected && (linkController.text.isEmpty || !isValidUrl(linkController.text))) {
                            //             ScaffoldMessenger.of(context).showSnackBar(
                            //               const SnackBar(content: Text("Please provide a valid link")),
                            //             );
                            //             return;
                            //           }
                            //           _updateResource(); // Proceed to create the resource
                            //         }
                            //       },
                            //       child: const Text("Add Resource"),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 16.0),
                          ],
                        ),
                      )
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Update Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
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
                        _updateResource();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Center(
                      child: const Text(
                        'Update Resource',
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
                        'Delete Resource',
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