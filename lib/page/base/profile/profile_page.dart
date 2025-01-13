import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/user_badge.dart';
import 'package:studysama/models/user_follow.dart';

import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../models/user_course.dart';
import '../../../models/badge_achievement.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import '../general_user_list_page.dart';
import '../my_course/course_detail_page.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;

  List<UserFollow> userFollower = [];
  List<UserFollow> userFollowing = [];

  List<User> userDataFollower = [];
  List<User> userDataFollowing = [];

  List<Course> createdCourses = [];
  List<UserCourse> createdUserCourses = []; //tutor

  List<Course> joinedCourses = [];
  List<UserCourse> joinedUserCourses = []; //tutor

  List<UserBadge> userBadges = [];

  String token = "";
  User? user;
  bool isLoading = true; // Add a loading state

  int? selectedBadgeIndex;
  bool isFlipping = false;

  // final List<String> badges = [
  //   'assets/badges/Badge1_transparent.png',
  //   'assets/badges/Badge2_transparent.png',
  //   'assets/badges/Badge3_transparent.png',
  //   'assets/badges/Badge4_transparent.png',
  // ];

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
    await fetchCourses();
    await fetchUserBadge();
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
        user = User.fromJson(data['user']);
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
      final data = await apiService.index_course(token, null);

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
      final data = await apiService.index_follow(token, null);

      final userFollowingMap = {
        for (var file in (data['following'] as List))
          file['id']: User.fromJson(file)
      };

      final userFollowerMap = {
        for (var file in (data['follower'] as List))
          file['id']: User.fromJson(file)
      };

      setState(() {
        userFollower = (data['user_follower'] as List)
            .map((json) {
          final follower = UserFollow.fromJson(json);
          follower.userFollower = userFollowerMap[follower.userFollowerId];
          return follower;
        }).toList();

        userDataFollower = (data['follower'] as List)
            .map((json) => User.fromJson(json))
            .toList();

        userFollowing = (data['user_following'] as List)
            .map((json) {
          final following = UserFollow.fromJson(json);
          following.userFollowed = userFollowingMap[following.userFollowedId];
          return following;
        }).toList();

        userDataFollowing = (data['following'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      });

      // setState(() {
      //   userFollowing = (data['user_following'] as List)
      //       .map((json) => UserFollow.fromJson(json))
      //       .toList();
      //
      //   userFollower = (data['user_follower'] as List)
      //       .map((json) => UserFollow.fromJson(json))
      //       .toList();
      //
      // });
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

  Future<void> fetchUserBadge() async {
    setState(() {
      // context.loaderOverlay.show();
      isLoading = true;
      // errorMessage = null;
    });

    // print('token: ' + token);
    try {
      final data = await apiService.index_user_badge(token, null);

      final badgesMap = {
        for (var file in (data['badges'] as List))
          file['id']: BadgeAchievement.fromJson(file)
      };

      setState(() {
        // userBadges = (data['userBadges'] as List)
        //     .map((json) => UserBadge.fromJson(json))
        //     .toList();

        userBadges = (data['user_badges'] as List)
            .map((json) {
          final userbadge = UserBadge.fromJson(json);
          userbadge.badgeAchievement = badgesMap[userbadge.badgeId];
          return userbadge;
        }).toList();

        print(userBadges[1].badgeAchievement!.logoImage!);

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
      body: Column(
        children: <Widget>[
          // Top Purple Section with Rounded Bottom Corners
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Container(
              color: AppColors.primary,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!isLoading) ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Username
                              Text(
                                '@' + (user?.username ?? 'null'),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 16),
                              // Circular Profile Picture Placeholder
                              // Container(
                              //   width: screenWidth * 0.25,
                              //   height: screenWidth * 0.25,
                              //   decoration: BoxDecoration(
                              //     shape: BoxShape.circle,
                              //     color: Colors.grey[300],
                              //     image: user?.image != null
                              //         ? DecorationImage(
                              //       image: NetworkImage(domainURL + '/storage/${user!.image!}'),
                              //       fit: BoxFit.cover,
                              //     )
                              //         : null,
                              //   ),
                              //   child: user?.image == null
                              //       ? Center(
                              //     child: Text(
                              //       user?.username != null
                              //           ? user!.username[0].toUpperCase()
                              //           : '?',
                              //       style: TextStyle(
                              //         fontSize: 24,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.black54,
                              //       ),
                              //     ),
                              //   )
                              //       : null,
                              // ),
                              GestureDetector(
                                onTap: () {
                                  if (user?.image != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.all(0),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context), // Close dialog on tap outside
                                                child: Container(
                                                  color: Colors.black.withOpacity(0.7), // Background overlay
                                                ),
                                              ),
                                              Center(
                                                child: Image.network(
                                                  domainURL + '/storage/${user!.image!}',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Positioned(
                                                top: 10, // Adjust this for proper placement
                                                right: 10, // Adjust this for proper placement
                                                child: GestureDetector(
                                                  onTap: () => Navigator.pop(context), // Close dialog
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black.withOpacity(0.6),
                                                    ),
                                                    padding: EdgeInsets.all(8), // Add padding for better tap area
                                                    child: Icon(
                                                      FontAwesomeIcons.xmark,
                                                      color: Colors.white
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  width: screenWidth * 0.25,
                                  height: screenWidth * 0.25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    image: user?.image != null
                                        ? DecorationImage(
                                      image: NetworkImage(domainURL + '/storage/${user!.image!}'),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: user?.image == null
                                      ? Center(
                                    child: Text(
                                      user?.username != null ? user!.username[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                      : null,
                                ),
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
                                  _buildStatColumn('Followers', userFollower.length.toString() ?? '0', screenWidth, userFollower),
                                  SizedBox(width: screenWidth * 0.05),
                                  _buildStatColumn('Following', userFollowing.length.toString() ?? '0', screenWidth, userFollowing),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildResponsiveButton(
                                    context,
                                    'Edit Profile',
                                    screenWidth,
                                    AppColors.primary,
                                    Colors.white,
                                    onPressed: () {
                                      if(user != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProfilePage(user: user!),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ] else ...[
                          Expanded(
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
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
                          borderRadius: BorderRadius.circular(20),
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
                                        user?.name ?? 'null',
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
                                          user?.bio ?? 'No bio available',
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
                                        user?.email ?? 'null',
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
                                        user?.phoneNum ?? '-',
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
                      Tab(text: "Badge"),
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
                        color: Colors.white
                    ),
                    indicatorColor: AppColors.secondary,
                    indicatorWeight: 5,
                  ),
                ],
              ),
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
                _buildBadgeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, double screenWidth, List<UserFollow> userFollows) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          String title = '';
          if(label == "Followers") {
            title = "follower";
          } else {
            title = "following";
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GeneralUserListPage(title: title, userFollows: userFollows,),
            ),
          );
        },
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildResponsiveButton(
      BuildContext context, String label, double screenWidth, Color fgColor, Color bgColor,
      {required VoidCallback onPressed}) {
    return SizedBox(
      width: screenWidth * 0.6,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: fgColor,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // Updated to 14
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: fgColor,
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

  Widget _buildBadgeTab() {
    if (userBadges.isEmpty) {
      // Show "No badge earned" message if the list is empty
      return Center(
        child: Text(
          "No badge earned.",
        ),
      );
    }

    // Otherwise, show the grid of badges
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: userBadges.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showBadgeDetail(index),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/badges/' + userBadges[index].badgeAchievement!.logoImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetail(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: BadgeDetailCard(
          badgeAsset: userBadges[index],
        ),
      ),
    );
  }
}

class BadgeDetailCard extends StatefulWidget {
  final UserBadge badgeAsset;

  const BadgeDetailCard({
    Key? key,
    required this.badgeAsset,
  }) : super(key: key);

  @override
  _BadgeDetailCardState createState() => _BadgeDetailCardState();
}

class _BadgeDetailCardState extends State<BadgeDetailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isBackView = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controller.isAnimating) return;

    if (_controller.value == 0.0) {
      _controller.forward().then((_) {
        setState(() => _isBackView = true);
      });
    } else {
      _controller.reverse().then((_) {
        setState(() => _isBackView = false);
      });
    }
  }

  String formatDate(DateTime date) {
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm a");
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(_controller.value * math.pi),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  child: _isBackView && _controller.value >= 0.5
                      ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.badgeAsset.badgeAchievement!.desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Date Earned",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatDate(widget.badgeAsset.createdAt!.toLocal()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Tap to flip back",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.tertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                      : Image.asset(
                    'assets/badges/' + widget.badgeAsset.badgeAchievement!.logoImage!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

