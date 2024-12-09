import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class HomePage extends StatelessWidget {
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
                      ),
                      SizedBox(width: 16),
                      courseCard(
                        title: 'CODING',
                        subtitle: 'Learn new coding',
                        image: "assets/coding.jpeg",
                        totalJoined: 350,
                      ),
                      SizedBox(width: 16),
                      courseCard(
                        title: 'LANGUAGE',
                        subtitle: 'Master a new language',
                        image: "assets/language.png",
                        totalJoined: 200,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Popular Courses Section
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
                      author: 'John',
                      title: 'Mathematics Mastery',
                      image: "assets/math.jpeg",
                      description: 'A comprehensive guide to mastering math.',
                      rating: 4.5,
                      duration: '2 hours',
                    ),
                    SizedBox(height: 10),
                    popularCourseCard(
                      author: 'Siti',
                      title: 'Explore Science Wonders',
                      image: "assets/science.jpeg",
                      description: 'Dive deep into the wonders of science.',
                      rating: 4.7,
                      duration: '3 hours',
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Class Schedules Section (formerly Live Location for Classes)
                Text(
                  'Class Schedules',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    // Physical Class
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Physical Classes',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          classDetail(
                            course: 'CODING',
                            username: 'James Brown',
                            location: 'Room 101, Building A',
                            time: '10:00 AM',
                            date: '2024-12-10',
                          ),
                        ],
                      ),
                    ),
                    // Online Class
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Online Classes',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          classDetail(
                            course: 'SCIENCE',
                            username: 'Sarah Lee',
                            location: 'Online (Zoom)',
                            time: '1:00 PM',
                            date: '2024-12-11',
                          ),
                        ],
                      ),
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

  // Widget for displaying a course card (Horizontal Scrolling)
  Widget courseCard({
    required String title,
    required String subtitle,
    required String image,
    required int totalJoined,
  }) {
    return Container(
      width: 250,
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              height: 140,
              width: double.infinity,
            ),
          ),
          // Details
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
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$totalJoined Enrolled',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
    required String author,
    required String title,
    required String image,
    required String description,
    required double rating,
    required String duration,
  }) {
    return Container(
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
          // Full-Width Course Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '$rating',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Spacer(),
                    Text(
                      duration,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for displaying class details
  Widget classDetail({
    required String course,
    required String username,
    required String location,
    required String time,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: $course',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text('Instructor: $username'),
            SizedBox(height: 6),
            Text('Location: $location'),
            SizedBox(height: 6),
            Text('Time: $time'),
            SizedBox(height: 6),
            Text('Date: $date'),
          ],
        ),
      ),
    );
  }
}
