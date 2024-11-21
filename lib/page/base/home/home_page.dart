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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/logo.jpg", // Replace with your actual logo path
                        height: 50,
                        width: 50,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'STUDYSAMA',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          // Handle menu action
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Welcome Section in a Bigger Horizontal Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.purple[800],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WELCOME TO STUDYSAMA!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28, // Bigger text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'where you can learn a lot of new things.',
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 18, // Bigger description
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Lessons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LESSONS',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to view more page
                      },
                      child: Text(
                        'View More',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      lessonCard(
                        title: 'RECIPE',
                        subtitle: 'discover new recipes',
                        image: "assets/recipe.jpeg", // Correct path
                      ),
                      SizedBox(width: 16),
                      lessonCard(
                        title: 'CODING',
                        subtitle: 'learn new coding',
                        image: "assets/coding.jpeg", // Correct path
                      ),
                      SizedBox(width: 16),
                      lessonCard(
                        title: 'LANGUAGE',
                        subtitle: 'improve language skills',
                        image: "assets/language.png", // Correct path
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
                Container(
                  height: 200, // Set a fixed height for vertical scrolling
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        popularLessonCard(
                          title: 'MATH 101',
                          subtitle: 'understand basic mathematics concepts',
                          image: "assets/math.jpeg", // Math image
                          rating: 4.9,
                        ),
                        SizedBox(height: 10),
                        popularLessonCard(
                          title: 'SCIENCE EXPLORATION',
                          subtitle: 'explore interesting science topics',
                          image: "assets/science.jpeg", // Science image
                          rating: 4.7,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20), // To avoid overflow at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for Lesson Card
  Widget lessonCard({required String title, required String subtitle, required String image}) {
    return Container(
      width: 150,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Popular Lesson Card with Rating
  Widget popularLessonCard({
    required String title,
    required String subtitle,
    required String image,
    required double rating,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[800],
      ),
      child: Row(
        children: [
          // Popular Lesson image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: Image.asset(
              image,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
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
                ],
              ),
            ),
          ),
          // Rating Display
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 24,
                ),
                Text(
                  rating.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
