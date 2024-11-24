import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        Map<String, dynamic> userMap = jsonDecode(userString);
        user = User.fromJson(userMap);
      }
      setState(() {
        username = user?.username;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading username: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Original background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple, // Purple header
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/logo.jpg", // Replace with your logo path
                      height: 40,
                      width: 40,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'STUDYSAMA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu, color: Colors.white),
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
              ),

              // Rest of the Home Page content...
              Expanded(
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
                          color: Colors.purple,
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

                      // Other sections like Courses, Popular Courses, etc...
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
