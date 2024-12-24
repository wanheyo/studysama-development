import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/page/base/profile/edit_profile.dart';

import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../models/user_course.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import '../../models/user_follow.dart';
import 'my_course/course_detail_page.dart';

class GeneralProfilePage extends StatefulWidget {
  final User user;
  const GeneralProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  _GeneralProfilePageState createState() => _GeneralProfilePageState();
}

class _GeneralProfilePageState extends State<GeneralProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;

  List<UserFollow> userFollower = [];
  List<UserFollow> userFollowing = [];
  bool isFollowedByYou = false;

  List<Course> createdCourses = [];
  List<UserCourse> createdUserCourses = []; //tutor

  List<Course> joinedCourses = [];
  List<UserCourse> joinedUserCourses = []; //tutor

  String token = "";
  User? userNow;
  bool isLoading = true; // Add a loading state

  String responseMessage = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs now

    initializeData();
  }

  Future<void> initializeData() async {
    await loadUser();
    await fetchUser();
    await fetchUserFollow();
    fetchCourses();
    //
    // // Apply filters for both Created and Joined Courses
    // _applyFiltersAndSortCourse(true);  // Filter created courses
    // _applyFiltersAndSortCourse(false); // Filter joined courses
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

  Future<void> fetchUser() async {
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
      // context.loaderOverlay.show();
      isLoading = true;
      // errorMessage = null;
    });

    // print('token: ' + token);
    try {
      final data = await apiService.index_course(token, widget.user.id);

      final tutorCreatedMap = {
        for (var file in (data['tutors_created'] as List))
          file['id']: User.fromJson(file)
      };

      final tutorJoinedMap = {
        for (var file in (data['tutors_joined'] as List))
          file['id']: User.fromJson(file)
      };

      setState(() {
        createdCourses = (data['created_course'] as List)
            .map((json) => Course.fromJson(json))
            .toList();

        createdUserCourses = (data['user_courses_created'] as List)
            .map((json) {
          final userCourse = UserCourse.fromJson(json);
          userCourse.user = tutorCreatedMap[userCourse.userId];
          return userCourse;
        }).toList();

        for(int i = 0; i < createdCourses.length; i++) {
          for (UserCourse uc in createdUserCourses) {
            if (createdCourses[i].id == uc.courseId) {
              createdCourses[i].tutor = uc.user;
            }
          }
        }

        joinedCourses = (data['joined_course'] as List)
            .map((json) => Course.fromJson(json))
            .toList();

        joinedUserCourses = (data['user_courses_joined'] as List)
            .map((json) {
          final userCourse = UserCourse.fromJson(json);
          userCourse.user = tutorJoinedMap[userCourse.userId];
          return userCourse;
        }).toList();

        for(int i = 0; i < joinedCourses.length; i++) {
          for (UserCourse uc in joinedUserCourses) {
            if (joinedCourses[i].id == uc.courseId) {
              joinedCourses[i].tutor = uc.user;
            }
          }
        }

        // _applyFiltersAndSortCourse(true);
      });
    } catch (e) {
      setState(() {
        // errorMessage = e.toString();
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        // context.loaderOverlay.hide();
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserFollow() async {
    setState(() {
      // context.loaderOverlay.show();
      isLoading = true;
      // errorMessage = null;
    });

    try {
      final data = await apiService.index_follow(token, widget.user.id);

      setState(() {
        userFollowing = (data['user_following'] as List)
            .map((json) => UserFollow.fromJson(json))
            .toList();

        userFollower = (data['user_follower'] as List)
            .map((json) => UserFollow.fromJson(json))
            .toList();

        for(UserFollow uf in userFollower) {
          if(uf.userFollowerId == userNow?.id)
            isFollowedByYou = true;
        }

      });
    } catch (e) {
      setState(() {
        // errorMessage = e.toString();
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        // context.loaderOverlay.hide();
        isLoading = false;
      });
    }
  }

  Future<void> updateFollow() async {
    setState(() {
      // context.loaderOverlay.show();
      // isLoading = true;
      // errorMessage = null;
    });

    try {
      final data = await apiService.update_follow(token, widget.user.id);

      setState(() {
        responseMessage = data['message'];

        print(responseMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseMessage)),
        );

        isFollowedByYou = false;
      });
    } catch (e) {
      setState(() {
        // errorMessage = e.toString();
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        // context.loaderOverlay.hide();
        // isLoading = false;
        initializeData();
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences

    // Navigate back to the login screen (replace this with your LoginPage route)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "@" + widget.user.username,
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Top Purple Section
          Container(
            color: AppColors.primary,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Information
                      if (!isLoading) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // // Username
                            // Text(
                            //   '@' + (widget.user.username ?? 'null'),
                            //   style: TextStyle(
                            //     fontFamily: 'Montserrat',
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.white,
                            //     fontSize: 14,
                            //   ),
                            //   overflow: TextOverflow.ellipsis, // Handle long names
                            // ),
                            // SizedBox(height: 16),
                            // Circular Profile Picture Placeholder
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                image: widget.user.image != null
                                    ? DecorationImage(
                                  image: NetworkImage(domainURL + '/storage/${widget.user.image!}',),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: widget.user.image == null
                                  ? Center(
                                child: Text(
                                  widget.user.username != null
                                      ? widget.user.username[0].toUpperCase()
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
                            SizedBox(height: 16),
                          ],
                        ),
                        Spacer(),
                        // Follower and Post Information
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                _buildStatColumn('Followers', userFollower.length.toString() ?? '0', screenWidth),
                                SizedBox(width: screenWidth * 0.05),
                                _buildStatColumn('Following', userFollowing.length.toString() ?? '0', screenWidth),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildResponsiveButton(
                                  context,
                                  isFollowedByYou ? 'Followed' : 'Follow',
                                  screenWidth,
                                  onPressed: () {
                                    updateFollow();
                                  },
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                _buildResponsiveButton(
                                  context,
                                  'Share',
                                  screenWidth,
                                  onPressed: () {
                                    // Share profile action
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else ...[
                        // Blank content while loading
                        Expanded(
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white,),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isLoading) ...[
                  SizedBox(height: 12),
                  // User Info ExpansionTile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'User Info',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.solidUser, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.user.name ?? 'null',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.circleInfo, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.user.bio ?? 'No bio available',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.solidEnvelope, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.user.email ?? 'null',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(FontAwesomeIcons.phone, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.user.phoneNum ?? '-',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: AppColors.primary,
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
                  SizedBox(height: 12),
                ],
                // TabBar Section
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Created"),
                    Tab(text: "Joined"),
                    Tab(text: "Badge"), // Added new tab
                  ],
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  indicatorColor: AppColors.background,
                  indicatorWeight: 5,
                ),
              ],
            ),
          ),
          // Tab Bar View Section
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(createdCourses, "No created courses found.", true),
                _buildCoursesTab(joinedCourses, "No joined courses found.", false),
                _buildBadgeButtonTab(), // Added new tab content
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, double screenWidth) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveButton(BuildContext context, String label,
      double screenWidth,
      {required VoidCallback onPressed}) {
    return SizedBox(
      width: screenWidth * 0.3,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
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
                                    Text(
                                      course.name,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    // _highlightedText(
                                    //   course.name,
                                    //   _searchTerm,
                                    //   defaultStyle: TextStyle(
                                    //     color: Colors.black,
                                    //     fontWeight: FontWeight.bold,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    const SizedBox(height: 8),
                                    if(course.desc != null)
                                      Text(
                                        course.desc!,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    // _highlightedText(
                                    //   course.desc!,
                                    //   _searchTerm,
                                    //   defaultStyle: TextStyle(
                                    //     color: Colors.grey[700],
                                    //     fontSize: 14,
                                    //   ),
                                    // ),

                                    SizedBox(height: 8),
                                    // Total Joined and Rating
                                    Row(
                                      children: [
                                        Text(
                                          course.tutor?.username ?? "null",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                                )
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

  Widget _buildBadgeButtonTab() {
    // Simulate the number of courses created by the user.
    int coursesCreated = 5; // Replace this with dynamic data from your app

    // Check if the user has created at least 5 courses
    bool showCard = coursesCreated >= 5;

    return Center(
      child: showCard
          ? Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Icon (you can replace this with an actual icon or image)
            Icon(
              Icons.star, // Example: star icon
              size: 50,
              color: Colors.amber,
            ),
            SizedBox(height: 10),
            // Badge Text
            Text(
              "Congratulations!",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "You've created at least 5 courses!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : Text(
        "Keep going! Create 5 courses to earn a badge.",
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
