import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/user_course.dart';
import 'package:studysama/page/base/general_profile_page.dart';
import 'package:studysama/page/base/profile/profile_page.dart';
import 'package:studysama/utils/colors.dart';

import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../my_course/course_detail_page.dart';
import '../my_course/create_course_page.dart';

class FindPage extends StatefulWidget {
  final Function(int) onTabChange; // Callback function to change tab

  const FindPage({required this.onTabChange, Key? key}) : super(key: key);

  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Course> courses = [];
  List<UserCourse> userCourses = []; //tutor
  List<User> users = [];

  bool isLoading = true;
  String? errorMessage;

  String courseTab_selectedFilter = 'All'; // Default filter
  String courseTab_selectedSortOrder = 'Newest'; // Default sort order
  List<Course> filteredCourse = [];

  String userTab_selectedSortOrder = 'Name Ascending'; // Default sort order
  List<User> filteredUser = [];

  final TextEditingController _searchController = TextEditingController(); // Shared search controller
  String _searchTerm = ''; // Current search term

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;

  User? userNow;
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
    await fetchUser();
    await fetchCourses();
    _applyFiltersAndSortCourse();  // Filter created courses
    await fetchUsers();
    _applyFiltersAndSortUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months ${months > 1 ? 'months' : 'month'} ago';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years ${years > 1 ? 'years' : 'year'} ago';
    }
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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

  Future<void> fetchUser() async {
    setState(() {
      context.loaderOverlay.show();
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.index_user(token, null);
      setState(() {
        userNow = User.fromJson(data['user']);
        isLoading = false; // Set loading to false once data is fetched
      });
    } catch (e) {
      print("Response: " + e.toString());
      setState(() {
        isLoading = false; // Set loading to false even if there's an error
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
      final data = await apiService.index_all_course(token);

      final tutorMap = {
        for (var file in (data['tutors'] as List))
          file['id']: User.fromJson(file)
      };

      setState(() {
        courses = (data['courses'] as List)
            .map((json) => Course.fromJson(json))
            .toList();

        userCourses = (data['user_courses'] as List)
            .map((json) {
          final userCourse = UserCourse.fromJson(json);
          userCourse.user = tutorMap[userCourse.userId];
          return userCourse;
        }).toList();

        for(int i = 0; i < courses.length; i++) {
          for (UserCourse uc in userCourses) {
            if (courses[i].id == uc.courseId) {
              courses[i].tutor = uc.user;
            }
          }
        }

        //print('course: ' + courses.toString());
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        print("Response: " + e.toString());
      });
    } finally {
      // setState(() {
      //   context.loaderOverlay.hide();
      //   isLoading = false;
      // });
    }
  }

  void _applyFiltersAndSortCourse() {
    setState(() {
      List<Course> filteredCourses;

      if (courseTab_selectedFilter == 'All') {
        filteredCourses = courses;
      } else {
        int filterStars = int.parse(courseTab_selectedFilter.split(' ')[0]); // '5 Star' -> 5
        filteredCourses = courses
            .where((course) => course.averageRating.toInt() == filterStars)
            .toList();
      }

      // Sort courses
      if (courseTab_selectedSortOrder == 'Newest') {
        filteredCourses.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      } else if (courseTab_selectedSortOrder == 'Oldest') {
        filteredCourses.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      } else if (courseTab_selectedSortOrder == 'Most Joined') {
        filteredCourses.sort((a, b) => b.totalJoined.compareTo(a.totalJoined)); // Most joined first
      } else if (courseTab_selectedSortOrder == 'Least Joined') {
        filteredCourses.sort((a, b) => a.totalJoined.compareTo(b.totalJoined)); // Least joined first
      }

      // Apply search
      filteredCourse = _applySearchCourseToList(filteredCourses, _searchTerm);
    });
  }

  /// Filters a list of courses based on the search term (name or description).
  List<Course> _applySearchCourseToList(List<Course> courses, String searchTerm) {
    if (searchTerm.isEmpty) return courses;

    return courses.where((course) {
      final nameMatches = course.name.toLowerCase().contains(searchTerm.toLowerCase());
      final descMatches = (course.desc?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false);
      final tutorMatches = (course.tutor?.username.toLowerCase().contains(searchTerm.toLowerCase()) ?? false);

      return nameMatches || descMatches || tutorMatches;
    }).toList();
  }

  Future<void> fetchUsers() async {
    setState(() {
      context.loaderOverlay.show();
      isLoading = true;
      errorMessage = null;
    });

    // print('token: ' + token);
    try {
      final data = await apiService.index_all_user(token);
      setState(() {
        users = (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();

        //print('course: ' + courses.toString());
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

  void _applyFiltersAndSortUser() {
    setState(() {
      List<User> filteredUsers = users;

      print("filteredUsers: "  + filteredUsers.toString());

      // Sort users based on selected sort order
      switch (userTab_selectedSortOrder) {
        case 'Name Ascending':
          filteredUsers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case 'Name Descending':
          filteredUsers.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;
        case 'Most Followed':
          filteredUsers.sort((a, b) => b.totalFollower.compareTo(a.totalFollower));
          break;
        case 'Least Followed':
          filteredUsers.sort((a, b) => a.totalFollower.compareTo(b.totalFollower));
          break;
      }

      // Apply search
      filteredUser = _applySearchUserToList(filteredUsers, _searchTerm);
    });
  }

  /// Filters a list of courses based on the search term (name or description).
  List<User> _applySearchUserToList(List<User> users, String searchTerm) {
    if (searchTerm.isEmpty) return users;

    return users.where((user) {
      return user.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          (user.bio?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
            children: [
              Icon(
                FontAwesomeIcons.magnifyingGlass,
                color: Colors.white,
              ),
              const SizedBox(width: 8), // Space between the icon and text
              Text(
                ' | Find Course @ User',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ), // Rounded corners
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Courses"),
            Tab(text: "Users"),
          ],
          dividerHeight: 0,
          labelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.white),
          indicatorColor: AppColors.secondary,
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
            _buildCoursesTab(filteredCourse, "No courses found."),  // Pass `true` for Created Courses tab
            _buildUsersTab(filteredUser, "No users found."),   // Pass `false` for Joined Courses tab
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
        color: selected == label ? AppColors.secondary : Colors.grey[200],
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

  Widget _buildSearchBar(String hintText) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: 'Montserrat'),
        prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchTerm = value; // Update search term
          _applyFiltersAndSortCourse();
          _applyFiltersAndSortUser();
        });
      },
    );
  }

  Widget _buildCreateCourseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
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
          icon: const Icon(Icons.add),
          label: const Text(
            "Add New Course",
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
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
            style: defaultStyle?.copyWith(color: AppColors.tertiary), // Highlight matched text
          ),
          TextSpan(
            text: text.substring(endIndex), // Text after match
            style: defaultStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab(List<Course> courses, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: initializeData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar("Search by name or description"),
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
                        _buildSegmentedButton(
                            'All', courseTab_selectedFilter, (filter) {
                          courseTab_selectedFilter = filter;
                          _applyFiltersAndSortCourse();
                        }),

                        for (int i = 5; i >= 1; i--)
                          _buildSegmentedButton(
                              '$i Star', courseTab_selectedFilter, (filter) {
                            courseTab_selectedFilter = filter;
                            _applyFiltersAndSortCourse();
                          }),

                      ],
                    ),
                  ),
                ),
                // Add space between segmented buttons and dropdown
                const SizedBox(width: 16), // Adjust the width as needed
                // Sort Button fixed on the right
                DropdownButton<String>(
                  value: courseTab_selectedSortOrder,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      courseTab_selectedSortOrder = newValue!;
                      _applyFiltersAndSortCourse();
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
            // SizedBox(height: 16),
            // // if (isCreatedCourses) _buildCreateCourseButton(),
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
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                      ),
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full-Width Placeholder Image (Optional if `course.image` is available)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            child: course.image != null
                                ? Image.network(
                              domainURL + '/storage/${course.image}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            )
                                : Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.grey[300], // Blank grey background
                              child: Center(
                                child: Text(
                                  course.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black54,
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
                                    _highlightedText(
                                      course.tutor?.username ?? "null",
                                      _searchTerm,
                                      defaultStyle: TextStyle(fontSize: 12, color: Colors.grey[600])
                                    ),
                                    Spacer(),
                                    Text(
                                      "|",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Spacer(),
                                    Text(
                                      "${course.totalJoined} Joined",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Spacer(),
                                    Text(
                                      "|",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Spacer(),
                                    Text(
                                      "${formatDate(
                                          course.createdAt.toLocal())}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Spacer(flex: 5,),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(List<User> user, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: initializeData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar("Search by name or bio"),
            SizedBox(height: 6),
            // Filter and Sort Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: userTab_selectedSortOrder,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      // Update sorting logic
                      userTab_selectedSortOrder = newValue!;
                      _applyFiltersAndSortUser();
                    });
                  },
                  items: <String>['Name Ascending', 'Name Descending', 'Most Followed', 'Least Followed']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Users List
            Expanded(
              child: filteredUser.isEmpty
                  ? Center(
                child: Text(
                  emptyMessage,
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
              )
                  : ListView.builder(
                itemCount: filteredUser.length,
                itemBuilder: (context, index) {
                  final user = filteredUser[index];
                  return GestureDetector(
                    onTap: () {
                      if(userNow!.id == user.id) {
                        widget.onTabChange(4);
                      } else {
                        // Navigate to user detail page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeneralProfilePage(user: user),
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Circular Profile Picture Placeholder
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                image: user.image != null
                                    ? DecorationImage(
                                  image: NetworkImage(domainURL + '/storage/${user.image!}',),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: user.image == null
                                  ? Center(
                                child: Text(
                                  user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                            SizedBox(width: 12),
                            // User Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  _highlightedText(
                                    user.username,
                                    _searchTerm,
                                    defaultStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  // Text(
                                  //   user.name,
                                  //   style: TextStyle(
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  SizedBox(height: 4),
                                  // Bio (if exists)
                                  if (user.bio != null)
                                    _highlightedText(
                                      user.bio!,
                                      _searchTerm,
                                      defaultStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    // Text(
                                    //   user.bio!,
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     color: Colors.grey[600],
                                    //   ),
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                  SizedBox(height: 4),
                                  // Followers
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.userGroup,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '${user.totalFollower} Followers',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
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
