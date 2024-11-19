import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/utils/colors.dart';

import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import 'course_detail_page.dart';
import 'create_course_page.dart';

class MyCoursePage extends StatefulWidget {
  @override
  _MyCoursePageState createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Course> createdCourses = [];
  List<Course> joinedCourses = [];
  bool isLoading = true;
  String? errorMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  User? user;
  int user_id = 0;
  String token = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUser();
    fetchCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final userString = prefs.getString('user');
      // if (userString != null) {
      //   Map<String, dynamic> userMap = jsonDecode(userString);
      //   user = User.fromJson(userMap);
      //   user_id = user!.id;
      // }
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        token = tokenString;
      }

      setState(() {
        // context.loaderOverlay.show();
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        // context.loaderOverlay.hide();
      });
    }
  }

  Future<void> fetchCourses() async {
    setState(() {
      context.loaderOverlay.show();
      isLoading = true;
      errorMessage = null;
    });

    // print('token: ' + token);
    try {
      final data = await apiService.index_user_course(token);
      setState(() {
        createdCourses = (data['created_course'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
        joinedCourses = (data['joined_course'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
        isLoading = false;
      });
    }
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
      body: LoaderOverlay(
        child: TabBarView(
          key: _formKey, // Associate the form key with the Form widget
          controller: _tabController,
          children: [
            _buildCoursesTab(createdCourses, "No created courses found.", true),  // Pass `true` for Created Courses tab
            _buildCoursesTab(joinedCourses, "No joined courses found.", false),   // Pass `false` for Joined Courses tab
            // _buildMyCoursesTab(),
            // _buildJoinedCoursesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCoursesTab(List<Course> courses, String emptyMessage) {
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

  Widget _buildJoinedCoursesTab(List<Course> courses, String emptyMessage) {
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCoursePage()),);
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

  Widget _buildCoursesTab(List<Course> courses, String emptyMessage, bool isCreatedCourses) {
    return Column(
      children: [
        _buildSearchBar(),
        // Show "Create Course" button only for Created Courses
        if (isCreatedCourses) _buildCreateCourseButton(),
        // Courses List
        Expanded(
          child: courses.isEmpty
              ? Center(
            child: Text(
              emptyMessage,
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
          )
              : ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailPage(course: course,)),);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Title
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Total Joined and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total joined: ${course.totalJoined}",
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                            Text(
                              "Rating: ${course.averageRating.toStringAsFixed(1)}",
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Created Date
                        Text(
                          "Created on: ${course.createdAt}", // Assume course.createdDate is in a formatted string
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Join Button
                        Align(
                          alignment: Alignment.centerRight,
                          // child: ElevatedButton(
                          //   onPressed: course.role_id == 1 || course.role_id == 2
                          //       ? null // Disable button for the creator
                          //       // : course.role_id == 3
                          //       // ? null // Disable button if already joined
                          //       : () {
                          //     // Handle join action
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: course.role_id == 3
                          //         ? Colors.grey // Disable color for joined courses
                          //         : AppColors.primary, // Primary color for joinable courses
                          //     textStyle: const TextStyle(
                          //       fontFamily: 'Montserrat',
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          //   child: Text(
                          //     course.role_id == 1 || course.role_id == 2
                          //         ? "Creator"
                          //         : course.role_id == 3
                          //         ? "Joined"
                          //         : "Join",
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
