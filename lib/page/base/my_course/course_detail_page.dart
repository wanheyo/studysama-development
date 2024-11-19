import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/course.dart';
import '../../../models/course.dart';
import '../../../utils/colors.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  CourseDetailPage({required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: About, Lessons, Reviews
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.name,
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(FontAwesomeIcons.infoCircle), text: 'About'),
            Tab(icon: Icon(FontAwesomeIcons.book), text: 'Lessons'),
            Tab(icon: Icon(FontAwesomeIcons.star), text: 'Reviews'),
          ],
          labelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.white),
          indicatorColor: AppColors.background,
          indicatorWeight: 5,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(widget.course),
          _buildLessonsTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  // About Tab
  Widget _buildAboutTab(Course course) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            course.desc ?? "No description available.",
            style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 20),
          Text(
            "Total Joined: ${course.totalJoined}",
            style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 5),
          Text(
            "Total Visits: ${course.totalVisit}",
            style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 5),
          Text(
            "Average Rating: ${course.averageRating.toStringAsFixed(1)}",
            style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 5),
          Text(
            "Status: ${course.status == 1 ? 'Active' : 'Inactive'}",
            style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 10),
          Text(
            "Created At: ${course.createdAt.toLocal()}",
            style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat', color: Colors.grey),
          ),
          Text(
            "Updated At: ${course.updatedAt.toLocal()}",
            style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat', color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Lessons Tab
  Widget _buildLessonsTab() {
    return Center(
      child: Text(
        "Lessons will be displayed here.",
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
      ),
    );
  }

  // Reviews Tab
  Widget _buildReviewsTab() {
    return Center(
      child: Text(
        "Reviews will be displayed here.",
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
      ),
    );
  }
}
