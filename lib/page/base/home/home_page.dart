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
      appBar: AppBar(
        backgroundColor: Colors.purple, // Purple header
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

                // Courses Section
                Text(
                  'Courses',
                  style: TextStyle(
                    color: Colors.purple,
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
                        updated: '2024-11-21',
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
                        image: "assets/language.jpeg",
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
                    color: Colors.purple,
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
                      started: '2023-06-01',
                      updated: '2024-11-19',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                    color: Colors.purple,
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
                          color: Colors.purple,
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
}
