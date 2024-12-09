import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user.dart';
import '../../../utils/colors.dart';

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
      backgroundColor: Colors.grey[100],
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
                        'WELCOME TO StudySama!',
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
                      description: 'Explore the wonders of science and technology.',
                      image: "assets/science.jpeg",
                      rating: 4.8,
                      totalJoined: 950,
                      started: '2023-06-02',
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

  // Widget for displaying a course card
  Widget courseCard({
    required String title,
    required String subtitle,
    required String image,
    required int totalJoined,
    required String started,
    required String updated,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Started: $started',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Updated: $updated',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Total joined: $totalJoined',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for displaying a popular course card
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  'Rating: $rating',
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
                Text(
                  'Total joined: $totalJoined',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Started: $started',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Updated: $updated',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
