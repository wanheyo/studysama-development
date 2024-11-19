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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkStoredCredentials(); // Check for stored credentials
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve token and auto-login if valid
    final storedToken = prefs.getString('token');
    // final storedUser = prefs.getString('user');

    if (storedToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BasePage()),
      );
    }
  }

  void _login() async {
    final usernameOrEmail = _usernameOrEmailController.text.trim();
    final password = _passwordController.text;

    // User? user = await _auth.signInWithEmailAndPassword(email, password);
    //
    // if (user != null) {
    //   print("User is successfully login");
    //   Navigator.pushNamed(context, "/home");
    // } else {
    //   print("Error occured");
    // }
    //
    // // Perform auth logic here
    // print("Email: $email, Password: $password");

    bool _isLoading = false;

    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is invalid
    }

    setState(() {
      _isLoading = true;
      context.loaderOverlay.show();
    });

    try {
      // Call the API and get the response
      final loginResponse = await apiService.login(usernameOrEmail, password);

      // Save the token and user data to SharedPreferences
      await saveUserData(loginResponse.token, loginResponse.user);
      // print(loginResponse.user);

      // User user = User.fromJson(loginResponse.user);

      // Show success message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      _basepage(); // Navigate to the Home page
    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        _isLoading = false;
        context.loaderOverlay.hide();
      });
    }

  }

  Future<void> saveUserData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    await prefs.setString('token', token);

    // Save user data
    await prefs.setString('user', jsonEncode(user));

    print(prefs.getString('user'));

    // Optionally save individual user fields for easier access
    await prefs.setInt('userId', user['id']);
    await prefs.setString('username', user['username']);
    await prefs.setString('email', user['email']);
    await prefs.setString('name', user['name']);

    // // Save other relevant user fields
    // if (user['phone_num'] != null) {
    //   await prefs.setString('phoneNum', user['phone_num']);
    // }
    // if (user['bio'] != null) {
    //   await prefs.setString('bio', user['bio']);
    // }
    // await prefs.setInt('totalFollower', user['total_follower']);
    // await prefs.setString('averageRating', user['average_rating']);
    // await prefs.setInt('verificationStatus', user['verification_status']);
    // await prefs.setInt('status', user['status']);
  }

  void _signup() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignupPage()), (route) => false);
  }

  void _basepage() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BasePage()), (route) => false);
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
        
                  // Email TextFormField
                  TextFormField(
                    controller: _usernameOrEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Username / Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FontAwesomeIcons.solidEnvelope),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
        
                  // Password TextFormField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FontAwesomeIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
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
        
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        child: Text(
                          "Login",
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
        
                  // Forgot Password TextButton
                  TextButton(
                    onPressed: () {
                      // Navigate to password reset page or show a dialog
                    },
                    child: Text(
                      "Forgot Password?",
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
