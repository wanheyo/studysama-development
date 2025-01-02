import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/utils/colors.dart';

import '../../../models/user.dart';
import '../../../services/api_service.dart'; // Replace with your app colors

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String token = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? selectedImage; // Stores the selected or cropped image
  final ImagePicker _picker = ImagePicker();
  String selectedCountryCode = '+60'; // Default to Malaysia

  // Save profile changes
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      print("phone number: " + selectedCountryCode + _phoneController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!" + selectedCountryCode + _phoneController.text)),
      );
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    String? username = _usernameController.text.trim();
    if(username == widget.user.username)
      username = null;

    String? name = _nameController.text.trim();
    if(name == widget.user.name)
      name = null;

    String? bio = _bioController.text.trim();
    if(bio == widget.user.bio)
      bio = null;

    // New phone number handling
    String? phoneNum;
    String currentPhone = _phoneController.text.trim();
    if (currentPhone.isNotEmpty) {
      // Only process if there's a phone number entered
      String fullNumber = getFullPhoneNumber(); // Get combined number with country code
      if (fullNumber == widget.user.phoneNum) {
        phoneNum = null; // No change in phone number
      } else {
        phoneNum = fullNumber; // Use the new combined number
      }
    } else {
      phoneNum = null; // Handle empty phone number case
    }

    String? email = _emailController.text.trim();
    if(email == widget.user.email)
      email = null;
    print(email);

    setState(() {
      // context.loaderOverlay.show();
    });

    try {
      final updatedData = await apiService.user_update(token, username, name, bio, email, phoneNum, selectedImage, null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile update failed: $errorMsg')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        // context.loaderOverlay.hide();
      });
    }
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

  // Pick Image from Gallery
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

  // Crop the selected image
  Future<void> cropImage(File? imageFile) async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected for cropping!")),
      );
      return;
    }

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
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

  String extractPhoneDetails(String? fullNumber) {
    if (fullNumber != null && fullNumber.isNotEmpty) {
      // If number starts with +, extract the country code
      if (fullNumber.startsWith('+')) {
        // Find the position where the actual number starts after country code
        // For +60, it would start at index 3
        int countryCodeEndIndex = 3; // Adjust if your country code length varies
        selectedCountryCode = fullNumber.substring(0, countryCodeEndIndex);
        return fullNumber.substring(countryCodeEndIndex); // Return number without code
      }
    }
    return fullNumber ?? '';
  }

  // Add this helper function to your class
  String getFullPhoneNumber() {
    String number = _phoneController.text.trim();
    if (number.isEmpty) return '';

    // Remove any spaces from both parts
    String cleanPrefix = selectedCountryCode.replaceAll(' ', '');
    String cleanNumber = number.replaceAll(' ', '');

    // Ensure we don't double-add the country code
    if (cleanNumber.startsWith(cleanPrefix)) {
      return cleanNumber;
    }
    return '$cleanPrefix$cleanNumber';
  }

  bool canChangeUsername() {
    if (widget.user.lastChangedAt == null) return true;

    final lastChanged = widget.user.lastChangedAt!;  // Using the DateTime directly
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    return lastChanged.isBefore(oneWeekAgo);
  }

  String getRemainingTime() {
    if (widget.user.lastChangedAt == null) return '';

    final lastChanged = widget.user.lastChangedAt!;  // Using the DateTime directly
    final nextChange = lastChanged.add(Duration(days: 7));
    final now = DateTime.now();

    if (now.isAfter(nextChange)) return '';

    final remaining = nextChange.difference(now);
    return '${remaining.inDays}d ${remaining.inHours % 24}h remaining';
  }

  @override
  void initState() {
    super.initState();
    loadUser();

    _usernameController.text = widget.user.username;
    _nameController.text = widget.user.name;
    _bioController.text = widget.user.bio ?? '';
    _phoneController.text = extractPhoneDetails(widget.user.phoneNum);
    _emailController.text = widget.user.email;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture
            Center(
              child: Stack(
                children: [
                  // Show Selected or Default Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: selectedImage != null
                          ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                          : widget.user.image != null
                          ? DecorationImage(
                        image: NetworkImage(domainURL + '/storage/${widget.user.image!}',),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: (widget.user.image == null && selectedImage == null)
                        ? Center(
                      child: Text(
                        widget.user.username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Icon(FontAwesomeIcons.camera, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Edit Profile Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      helperText: canChangeUsername()
                          ? 'Username can be changed once per week'
                          : 'Username can be changed in ${getRemainingTime()}',
                      helperMaxLines: 2,
                    ),
                    enabled: canChangeUsername(), // Disable field if can't change
                    validator: (value) {
                      // if (!canChangeUsername()) {
                      //   return 'Username can only be changed once per week';
                      // }
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 6) {
                        return 'Username must be at least 6 characters';
                      }
                      if (value.length > 16) {
                        return 'Username must be at most 16 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Bio
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: "Bio (Optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: "Phone Number (Optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixText: '$selectedCountryCode ',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      // Proceed only if there's a value
                      if (value != null && value.isNotEmpty) {
                        // Remove any spaces from the input
                        String cleanValue = value.replaceAll(' ', '');

                        // Check minimum and maximum length for the raw input
                        if (cleanValue.length < 7) {
                          return "Phone number is too short";
                        }
                        if (cleanValue.length > 15) {
                          return "Phone number is too long";
                        }

                        // Add default country code if the number doesn't include a prefix
                        String phoneNumber = value.startsWith('+') ? value : '$selectedCountryCode$value';

                        try {
                          // Parse and validate the phone number
                          final parsedNumber = PhoneNumber.parse(phoneNumber);

                          // Check if the number is valid
                          if (!parsedNumber.isValid()) {
                            return "Invalid phone number";
                          }

                          // Additional length check for the specific country format
                          final nationalNumber = parsedNumber.nsn; // Get the national significant number
                          if (nationalNumber.length < 7) {
                            return "Phone number is too short for this country";
                          }
                          if (nationalNumber.length > 15) {
                            return "Phone number is too long for this country";
                          }
                        } catch (e) {
                          return "Invalid phone number format";
                        }
                      }

                      // Return null if the field is empty or the validation passes
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email TextField with validation
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // prefixIcon: Icon(FluentSystemIcons.ic_fluent_mail_filled),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Basic email validation
                      String emailPattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b';
                      RegExp regExp = RegExp(emailPattern);
                      if (!regExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    onPressed: _updateUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Center(
                      child: const Text(
                        'Save',
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
