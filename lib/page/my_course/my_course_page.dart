import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studysama/utils/colors.dart';

class MyCoursePage extends StatefulWidget {
  @override
  _MyCoursePageState createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.scroll,
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between the icon and text
            Text(
              ' | My Courses',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18
              ),
            ),
          ]
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Created Courses"),
            Tab(text: "Joined Courses"),
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
          // indicator: BoxDecoration(
          //     color: Colors.teal, borderRadius: BorderRadius.circular(8)),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyCoursesTab(),
          _buildJoinedCoursesTab(),
        ],
      ),
    );
  }

  Widget _buildMyCoursesTab() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCreateCourseButton(),
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Replace with your course count
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Course ${index + 1}', style: const TextStyle(fontFamily: 'Montserrat')),
                subtitle: Text('Description of Course ${index + 1}'),
                onTap: () {
                  // Navigate to course details
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJoinedCoursesTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView.builder(
            itemCount: 3, // Replace with your joined course count
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Joined Course ${index + 1}', style: const TextStyle(fontFamily: 'Montserrat')),
                subtitle: Text('Description of Joined Course ${index + 1}'),
                onTap: () {
                  // Navigate to joined course details
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: const TextStyle(fontFamily: 'Montserrat'),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          // Add search functionality
        },
      ),
    );
  }

  Widget _buildCreateCourseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to create course page
        },
        icon: const Icon(Icons.add),
        label: const Text(
          "Add New Course",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }
}
