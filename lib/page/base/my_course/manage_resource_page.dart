import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:studysama/models/resource.dart';

import '../../../services/api_service.dart';

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
        'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx',
        'png', 'jpg', 'jpeg'
      ],
    );

    if (result != null) {
      if (result.files.single.size <= 5 * 1024 * 1024) {
        selectedFile = File(result.files.single.path!);
        setState(() {
          fileName = result.files.single.name; // Update with selected file name
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File size exceeds the 5MB limit!")),
        );
      }
    }
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

    int isUpdateFile = 0;
    if(isFileUploadSelected)
      isUpdateFile = 1;

    if (widget.resource.resourceFile != null) {
      try {
        // Call the API
        await apiService.resource_update(token, isUpdateFile, name, desc, category, link, widget.resource.id, "", "", widget.resource.resourceFile?.id, selectedFile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Resources "$name" created successfully',
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
    }

    Navigator.pop(context); // Close the page after creating the resource
  }

  @override
  void initState() {
    super.initState();
    loadUser();

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
        title: Text("Add New Resource"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
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
                                // nameController.clear();
                                // descController.clear();
                                // linkController.clear();
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
                    labelText: 'Resource Name',
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
                    hintText: ' It is note? Or an assignment?',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the page without saving
                      },
                      child: const Text("Cancel"),
                    ),
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
                          _updateResource(); // Proceed to create the resource
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
  }
}