import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/utils/colors.dart';

import '../../../models/course.dart';
import '../../../models/tutor_slot.dart';
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

  String createdCourseTab_selectedFilter = 'All'; // Default filter
  String createdCourseTab_selectedSortOrder = 'Newest'; // Default sort order
  List<Course> filteredCreatedCourse = [];

  String joinedCourseTab_selectedFilter = 'All'; // Default filter
  String joinedCourseTab_selectedSortOrder = 'Newest'; // Default sort order
  List<Course> filteredJoinedCourse = [];

  final TextEditingController _searchController = TextEditingController(); // Shared search controller
  String _searchTerm = ''; // Current search term

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String token = "";
  User? user;
  int user_id = 0;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUser();
    await fetchCourses();

    // Apply filters for both Created and Joined Courses
    _applyFiltersAndSortCourse(true);  // Filter created courses
    _applyFiltersAndSortCourse(false); // Filter joined courses
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm a");
    return dateFormat.format(date);
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
      final data = await apiService.index_course(token);
      setState(() {
        createdCourses = (data['created_course'] as List)
            .map((json) => Course.fromJson(json))
            .toList();
        joinedCourses = (data['joined_course'] as List)
            .map((json) => Course.fromJson(json))
            .toList();

        // _applyFiltersAndSortCourse(true);
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

  void _applyFiltersAndSortCourse(bool isCreatedCourse) {
    setState(() {
      List<Course> filteredCourses;

      // Apply filter
      if (isCreatedCourse) {
        if (createdCourseTab_selectedFilter == 'All') {
          filteredCourses = createdCourses;
        } else {
          int filterStars = int.parse(createdCourseTab_selectedFilter.split(' ')[0]); // '5 Star' -> 5
          filteredCourses = createdCourses
              .where((course) => course.averageRating.toInt() == filterStars)
              .toList();
        }

        // Sort courses
        if (createdCourseTab_selectedSortOrder == 'Newest') {
          filteredCourses.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        } else if (createdCourseTab_selectedSortOrder == 'Oldest') {
          filteredCourses.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        } else if (createdCourseTab_selectedSortOrder == 'Most Joined') {
          filteredCourses.sort((a, b) => b.totalJoined.compareTo(a.totalJoined)); // Most joined first
        } else if (createdCourseTab_selectedSortOrder == 'Least Joined') {
          filteredCourses.sort((a, b) => a.totalJoined.compareTo(b.totalJoined)); // Least joined first
        }

        // Apply search
        filteredCreatedCourse = _applySearchToList(filteredCourses, _searchTerm);
      } else {
        if (joinedCourseTab_selectedFilter == 'All') {
          filteredCourses = joinedCourses;
        } else {
          int filterStars = int.parse(joinedCourseTab_selectedFilter.split(' ')[0]); // '5 Star' -> 5
          filteredCourses = joinedCourses
              .where((course) => course.averageRating.toInt() == filterStars)
              .toList();
        }

        // Sort courses
        if (joinedCourseTab_selectedSortOrder == 'Newest') {
          filteredCourses.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        } else if (joinedCourseTab_selectedSortOrder == 'Oldest') {
          filteredCourses.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        } else if (joinedCourseTab_selectedSortOrder == 'Most Joined') {
          filteredCourses.sort((a, b) => b.totalJoined.compareTo(a.totalJoined)); // Most joined first
        } else if (joinedCourseTab_selectedSortOrder == 'Least Joined') {
          filteredCourses.sort((a, b) => a.totalJoined.compareTo(b.totalJoined)); // Least joined first
        }

        // Apply search
        filteredJoinedCourse = _applySearchToList(filteredCourses, _searchTerm);
      }
    });
  }

  /// Filters a list of courses based on the search term (name or description).
  List<Course> _applySearchToList(List<Course> courses, String searchTerm) {
    if (searchTerm.isEmpty) return courses;

    return courses.where((course) {
      return course.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          (course.desc?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false);
    }).toList();
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
            _buildCoursesTab(filteredCreatedCourse, "No created courses found.", true),  // Pass `true` for Created Courses tab
            _buildCoursesTab(filteredJoinedCourse, "No joined courses found.", false),   // Pass `false` for Joined Courses tab
            // _buildMyCoursesTab(),
            // _buildJoinedCoursesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedButton(String label, String selected, Function(String) onPressed) {
    return GestureDetector(
      onTap: () => onPressed(label),
      child: Card(
        color: selected == label ? AppColors.primary : Colors.grey[200],
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: selected == label ? Colors.white : Colors.black,
              fontWeight: selected == label ? FontWeight.bold : FontWeight.normal, // Set font weight
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search by name or description",
        hintStyle: const TextStyle(fontFamily: 'Montserrat'),
        prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchTerm = value; // Update search term
          _applyFiltersAndSortCourse(true); // Adjust for created courses
          _applyFiltersAndSortCourse(false); // Adjust for joined courses
        });
      },
    );
  }

  Widget _buildCreateCourseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Navigate to CreateCoursePage with a callback
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCoursePage(
                onCourseCreated: fetchCourses, // Pass the fetchCourses function
              ),
            ),
          );
        },
        icon: const Icon(FontAwesomeIcons.plus),
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

  Widget _highlightedText(String text, String query, {TextStyle? defaultStyle}) {
    if (query.isEmpty) return Text(text, style: defaultStyle);

    final matches = query.toLowerCase();
    final textLower = text.toLowerCase();
    final startIndex = textLower.indexOf(matches);
    if (startIndex == -1) return Text(text, style: defaultStyle); // No match found

    final endIndex = startIndex + matches.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, startIndex), // Text before match
            style: defaultStyle,
          ),
          TextSpan(
            text: text.substring(startIndex, endIndex), // Matched text
            style: defaultStyle?.copyWith(color: AppColors.primary), // Highlight matched text
          ),
          TextSpan(
            text: text.substring(endIndex), // Text after match
            style: defaultStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab(List<Course> courses, String emptyMessage, bool isCreatedCourses) {
    return RefreshIndicator(
      onRefresh: initializeData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 6),
            // Filter and Sort Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Segmented Button for Filter with horizontal scrolling
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if(isCreatedCourses)
                          _buildSegmentedButton(
                              'All', createdCourseTab_selectedFilter, (filter) {
                            createdCourseTab_selectedFilter = filter;
                            _applyFiltersAndSortCourse(isCreatedCourses);
                          }),

                        if(!isCreatedCourses)
                          _buildSegmentedButton(
                              'All', joinedCourseTab_selectedFilter, (filter) {
                            joinedCourseTab_selectedFilter = filter;
                            _applyFiltersAndSortCourse(isCreatedCourses);
                          }),

                        if(isCreatedCourses)
                          for (int i = 5; i >= 1; i--)
                            _buildSegmentedButton(
                                '$i Star', createdCourseTab_selectedFilter, (filter) {
                              createdCourseTab_selectedFilter = filter;
                              _applyFiltersAndSortCourse(isCreatedCourses);
                            }),

                        if(!isCreatedCourses)
                          for (int i = 5; i >= 1; i--)
                            _buildSegmentedButton(
                                '$i Star', joinedCourseTab_selectedFilter, (filter) {
                              joinedCourseTab_selectedFilter = filter;
                              _applyFiltersAndSortCourse(isCreatedCourses);
                            }),
                      ],
                    ),
                  ),
                ),
                // Add space between segmented buttons and dropdown
                const SizedBox(width: 16), // Adjust the width as needed
                // Sort Button fixed on the right
                DropdownButton<String>(
                  value: isCreatedCourses ? createdCourseTab_selectedSortOrder : joinedCourseTab_selectedSortOrder,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      if(isCreatedCourses)
                        createdCourseTab_selectedSortOrder = newValue!;
                      _applyFiltersAndSortCourse(isCreatedCourses);
                    });
                  },
                  items: <String>['Newest', 'Oldest', 'Most Joined', 'Least Joined']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (isCreatedCourses) _buildCreateCourseButton(),
            SizedBox(height: 16),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(course: course),
                        ),
                      ).then((_) {
                        // Refresh the courses when returning from CourseDetailPage
                        initializeData();
                      });
                    },
                    child: Container(
                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full-Width Placeholder Image (Optional if `course.image` is available)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              child:
                              // course.image != null && course.image.isNotEmpty
                              //     ? Image.asset(
                              //   course.image,
                              //   fit: BoxFit.cover,
                              //   width: double.infinity,
                              //   height: 180,
                              // ) :
                              Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[300], // Blank grey background
                                child: Center(
                                  child: Text(
                                    course.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Course Name
                                  // Text(
                                  //   course.name,
                                  //   style: TextStyle(
                                  //     color: AppColors.primary,
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize: 16,
                                  //   ),
                                  // ),
                                  _highlightedText(
                                    course.name,
                                    _searchTerm,
                                    defaultStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if(course.desc != null)
                                    if (course.desc != null)
                                      _highlightedText(
                                        course.desc!,
                                        _searchTerm,
                                        defaultStyle: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    // Text(
                                    //   course.desc!,
                                    //   style: TextStyle(
                                    //     color: Colors.grey[700],
                                    //     fontSize: 14,
                                    //   ),
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                  SizedBox(height: 8),
                                  // Total Joined and Rating
                                  Row(
                                    children: [
                                      Text(
                                        "${course.totalJoined} Joined",
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "${formatDate(
                                            course.createdAt.toLocal())}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            course.averageRating.toStringAsFixed(1),
                                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 8),
                                  // // Created Date
                                  // Text(
                                  //   "Created on: ${course.createdAt}",
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: Colors.grey[600],
                                  //   ),
                                  // ),
                                ],
                              ),
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
        ),
      ),
    );
  }
}
