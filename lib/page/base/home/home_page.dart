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

import '../../../models/user.dart';
<<<<<<< HEAD
import '../../../services/api_service.dart';
import '../../../services/firebase_auth_services.dart';
=======
import '../../../utils/colors.dart';
>>>>>>> 5630eb342fc3e7e6dafb83e27b4b8e50ba4cd148

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
<<<<<<< HEAD
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
=======
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Purple header
        title: Row(
          children: [
            Image.asset(
              "assets/logo.jpg", // Replace with your logo path
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Text('STUDYSAMA'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu),
            onSelected: (value) {
              // Handle menu options
              if (value == 'Profile') {
                // Navigate to Profile
              } else if (value == 'Settings') {
                // Navigate to Settings
              } else if (value == 'Logout') {
                // Handle Logout
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Profile', child: Text('Profile')),
                PopupMenuItem(value: 'Settings', child: Text('Settings')),
                PopupMenuItem(value: 'Logout', child: Text('Logout')),
              ];
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100], // Original background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WELCOME TO STUDYSAMA!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Where you can learn a lot of new things.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Courses Section
                Text(
                  'Courses',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      courseCard(
                        title: 'RECIPE',
                        subtitle: 'Discover new recipes',
                        image: "assets/recipe.jpeg",
                        totalJoined: 120,
                        started: '2024-01-01',
                        updated: '2024-11-22',
                      ),
                      SizedBox(width: 16),
                      courseCard(
                        title: 'CODING',
                        subtitle: 'Learn new coding',
                        image: "assets/coding.jpeg",
                        totalJoined: 350,
                        started: '2023-05-12',
                        updated: '2024-10-15',
                      ),
                      SizedBox(width: 16),
                      courseCard(
                        title: 'LANGUAGE',
                        subtitle: 'Master a new language',
                        image: "assets/language.png",
                        totalJoined: 200,
                        started: '2024-03-10',
                        updated: '2024-11-20',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Most Popular Courses Section
                Text(
                  'Most Popular Courses',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    popularCourseCard(
                      title: 'MATH',
                      description:
                      'Master mathematical concepts and sharpen your problem-solving skills.',
                      image: "assets/math.jpeg",
                      rating: 4.9,
                      totalJoined: 1000,
                      started: '2023-07-01',
                      updated: '2024-11-20',
                    ),
                    SizedBox(height: 10),
                    popularCourseCard(
                      title: 'SCIENCE',
                      description:
                      'Explore the wonders of science and technology.',
                      image: "assets/science.jpeg",
                      rating: 4.8,
                      totalJoined: 950,
                      started: '2023-06-02',
                      updated: '2024-11-19',
>>>>>>> 5630eb342fc3e7e6dafb83e27b4b8e50ba4cd148
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
<<<<<<< HEAD
=======

  // Widget for Course Card
  Widget courseCard({
    required String title,
    required String subtitle,
    required String image,
    required int totalJoined,
    required String started,
    required String updated,
  }) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              image,
              height: 100,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Divider(color: Colors.grey[400]),
                Text(
                  'Total Joined: $totalJoined',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Started: $started',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                Text(
                  'Updated: $updated',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Popular Course Card
  Widget popularCourseCard({
    required String title,
    required String description,
    required String image,
    required double rating,
    required int totalJoined,
    required String started,
    required String updated,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.asset(
                  image,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Total Joined: $totalJoined',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        'Started: $started',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        'Updated: $updated',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Text(
                      '$rating',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
>>>>>>> 5630eb342fc3e7e6dafb83e27b4b8e50ba4cd148
}


