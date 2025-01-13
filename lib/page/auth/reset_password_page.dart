import 'dart:convert';
import 'dart:math';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/page/base/base_page.dart';
import 'package:studysama/page/auth/signup_page.dart';
import 'package:studysama/page/base/home/home_page.dart';
import 'package:studysama/utils/colors.dart';

import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/firebase_auth_services.dart';
import 'login_Page.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  final _emailController = TextEditingController();

  // final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  bool success = false;
  String message = "";
  String errors = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    super.dispose();
  }

  void forgotPassword() async {
    final email = _emailController.text.trim();

    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    context.loaderOverlay.show(); // Show loading overlay
    try {
      final response = await apiService.forgotPassword(email);

      setState(() {
        success = response['success'];
        message = response['message'];
        errors = response['errors'] ?? ''; // Handle validation errors (if any)
      });

      // Show appropriate snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      if (success) {
        // Optionally navigate to another screen on success
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()), // Example navigation
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      context.loaderOverlay.hide(); // Hide loading overlay
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoaderOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      Image.asset(
                        'assets/SS_Header_Transparent_16-9.png',
                        height: 150,
                      ),
                      SizedBox(height: screenHeight * 0.05),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          " Forgot password? Don't worry.",
                          style: TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Form fields section
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: Icon(FontAwesomeIcons.solidEnvelope),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.05),

                      // Buttons section
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: forgotPassword,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                            child: Text(
                              "Reset Password",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      TextButton(
                        onPressed: () {
                          // Navigate to password reset page or show a dialog
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                        },
                        child: Text("Back to login"),
                      ),

                      // Add bottom padding when keyboard is open
                      SizedBox(height: isKeyboardOpen ? screenHeight * 0.1 : screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
