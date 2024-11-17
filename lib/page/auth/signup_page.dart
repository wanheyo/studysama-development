import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:studysama/page/auth/login_Page.dart';
import 'package:studysama/services/firebase_auth_services.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }

  void _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool _isLoading = false;

    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    setState(() {
      _isLoading = true;
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.user_store(username, email, password);

      // Show success message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
      _login(); // Navigate to the login page
    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        _isLoading = false;
        context.loaderOverlay.hide();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoaderOverlay(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey, // Associate the form key with the Form widget
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 4), // Add some space at the top
                  Text(
                    "StudySama",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05), // 5% of screen height

                  // Username TextField with validation
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 6) {
                        return 'Username must be at least 6 characters';
                      }
                      if (value.length > 30) {
                        return 'Username must be at most 30 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height

                  // Email TextField with validation
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FluentSystemIcons.ic_fluent_mail_filled),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height

                  // Password TextField with validation
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FluentSystemIcons.ic_fluent_lock_filled),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? FluentSystemIcons.ic_fluent_eye_show_filled : FluentSystemIcons.ic_fluent_eye_hide_filled,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // Validate password length
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05), // 5% of screen height

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signup,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: Colors.blue,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      // ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height

                  // Back to login TextButton
                  TextButton(
                    onPressed: _login,
                    child: Text(
                      "Already have an account?",
                      // style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  Spacer(flex: 3), // Add some space at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
