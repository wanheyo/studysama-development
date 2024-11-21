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
        backgroundColor: Colors.purple,
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
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Handle menu action
            },
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
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
                    SizedBox(height: 8),
                    Text(
                      'where you can learn a lot of new things.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Lessons Section
              Text(
                'LESSONS',
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
                    lessonCard(
                      title: 'RECIPE',
                      subtitle: 'Discover new recipes',
                      image: "assets/recipe.jpeg",
                      totalVisits: 120,
                      createdAt: '2024-01-01',
                      updatedAt: '2024-11-21',
                    ),
                    SizedBox(width: 16),
                    lessonCard(
                      title: 'CODING',
                      subtitle: 'Learn new coding',
                      image: "assets/coding.jpeg",
                      totalVisits: 350,
                      createdAt: '2023-05-12',
                      updatedAt: '2024-10-15',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Most Popular Section
              Text(
                'MOST POPULAR LESSONS',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    popularLessonCard(
                      title: 'MATH',
                      image: "assets/math.jpeg",
                      totalVisits: 500,
                      rating: 4.9,
                      createdAt: '2022-08-10',
                      updatedAt: '2024-11-18',
                    ),
                    SizedBox(height: 16),
                    popularLessonCard(
                      title: 'SCIENCE',
                      image: "assets/science.jpeg",
                      totalVisits: 450,
                      rating: 4.8,
                      createdAt: '2023-01-20',
                      updatedAt: '2024-10-10',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Horizontal Lesson Card
  Widget lessonCard({
    required String title,
    required String subtitle,
    required String image,
    required int totalVisits,
    required String createdAt,
    required String updatedAt,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[900],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              image,
              height: 100,
              width: 200,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Visits: $totalVisits',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  'Created: $createdAt',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  'Updated: $updatedAt',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Popular Lesson Card
  Widget popularLessonCard({
    required String title,
    required String image,
    required int totalVisits,
    required double rating,
    required String createdAt,
    required String updatedAt,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[900],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Visits: $totalVisits',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  'Created: $createdAt',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  'Updated: $updatedAt',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(height: 4),
              Text(
                rating.toString(),
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
      padding: EdgeInsets.all(8),
    );
  }
}
