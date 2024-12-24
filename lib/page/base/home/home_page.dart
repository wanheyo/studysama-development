import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../models/user_course.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import '../my_course/course_detail_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange; // Callback function to change tab

  const HomePage({required this.onTabChange, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState  extends  State<HomePage> {
  final ApiService apiService = ApiService();
  String token = "";

  List<Course> courses = [];
  List<UserCourse> userCourses = []; //tutor
  List<User> users = [];

  List<Course> mostJoinedCourses = [];
  List<UserCourse> userCoursesPopular = []; //tutor

  List<Course> highestRatedCourses = [];
  List<UserCourse> userCoursesHighRating = []; //tutor

  bool isLoading = false;
  PageController _pageControllerMostJoined = PageController(); // PageController for PageView
  PageController _pageControllerHighestRated = PageController(); // PageController for PageView
  int _currentPageMostJoined = 0; // Current page index
  int _currentPageHighestRated = 0; // Current page index

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

  Future<void> fetchCourses() async {
    setState(() {
      // context.loaderOverlay.show();
      isLoading = true;
      // errorMessage = null;
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

        // Sort courses by total joined and average rating
        courses.sort((a, b) => b.totalJoined.compareTo(a.totalJoined)); // Most joined
        mostJoinedCourses = courses.take(5).toList();

        courses.sort((a, b) => b.averageRating.compareTo(a.averageRating)); // Highest rating
        highestRatedCourses = courses.take(5).toList();

        //print('course: ' + courses.toString());
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

  @override
  void initState() {
    super.initState();
    initializeData();
    _pageControllerHighestRated.addListener(() {
      setState(() {
        _currentPageHighestRated = _pageControllerHighestRated.page!.round(); // Update current page index
      });
    });
    _pageControllerMostJoined.addListener(() {
      setState(() {
        _currentPageMostJoined = _pageControllerMostJoined.page!.round(); // Update current page index
      });
    });
  }

  Future<void> initializeData() async {
    await loadUser();
    fetchCourses();
  }

  @override
  void dispose() {
    super.dispose();
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

                // Features Section
                Text(
                  'Features',
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
                      featureCard(
                        title: 'LEARN',
                        subtitle: 'Find and access quality study resources shared by others.',
                        image: 'assets/learn.png',
                      ),
                      const SizedBox(width: 16),
                      featureCard(
                        title: 'TEACH',
                        subtitle: 'Share your knowledge and help others succeed.',
                        image: 'assets/teach.png',
                      ),
                      const SizedBox(width: 16),
                      featureCard(
                        title: 'CONNECT',
                        subtitle: 'Connect with fellow learners and educators.',
                        image: 'assets/connect.png',
                      ),
                      const SizedBox(width: 16),
                      featureCard(
                        title: 'ACHIEVE',
                        subtitle: 'Track your progress and unlock exclusive rewards.',
                        image: 'assets/achievement.png',
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
                if (isLoading) // Show loading indicator if loading
                  Center(child: CircularProgressIndicator(color: AppColors.primary,))
                else
                // Use PageView for horizontal scrolling
                  Column(
                    children: [
                      Container(
                        height: 310, // Set a fixed height for the course list
                        child: PageView.builder(
                          controller: _pageControllerMostJoined,
                          itemCount: mostJoinedCourses.length + 1,
                          itemBuilder: (context, index) {
                            if (index < mostJoinedCourses.length) {
                              return buildCourseCard(mostJoinedCourses[index]);
                            } else {
                              return Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to the view more page or perform an action
                                    widget.onTabChange(1);
                                  },
                                  child: const Text("View More"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(mostJoinedCourses.length + 1, (index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageMostJoined == index
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                SizedBox(height: 20),

                // Highest Rated Courses Section
                Text(
                  'Highest Rated Courses',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                if (isLoading)
                  Center(child: CircularProgressIndicator(color: AppColors.primary,))
                else
                  Column(
                    children: [
                      Container(
                        height: 310, // Set a fixed height for the course list
                        child: PageView.builder(
                          controller: _pageControllerHighestRated,
                          itemCount: highestRatedCourses.length + 1,
                          itemBuilder: (context, index) {
                            if (index < highestRatedCourses.length) {
                              return buildCourseCard(highestRatedCourses[index]);
                            } else {
                              return Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to the view more page or perform an action
                                    widget.onTabChange(1);
                                  },
                                  child: const Text("View More"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(highestRatedCourses.length + 1, (index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageHighestRated == index
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),

                SizedBox(height: 20),

                // About Section
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
                        'ABOUT US',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'BITU3923 WORKSHOP II',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The “StudySama” Platform is a mobile-based solution aimed at improving access to quality education through peer learning.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This platform aligns with SDG 4 (Quality Education) by providing students the opportunity to either offer or receive tutoring in specific subjects, fostering an inclusive learning environment.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The project addresses the challenges faced by students in accessing affordable and effective educational support.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'With many students unable to afford private tutoring, this platform offers a cost-effective alternative by leveraging peer expertise.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // // Class Schedules Section
                // Text(
                //   'Class Schedules',
                //   style: TextStyle(
                //     color: AppColors.primary,
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 10),
                //
                // // Physical Classes at the Top
                // Container(
                //   padding: EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.blue[50], // Light blue for Physical
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Physical Classes',
                //         style: TextStyle(
                //           color: AppColors.primary,
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       SizedBox(height: 10),
                //       classScheduleWidget(
                //         icon: Icons.location_on,
                //         courseName: 'CODING',
                //         username: 'Alice',
                //         location: 'Room 101, Main Building',
                //         time: '10:00 AM - 12:00 PM',
                //         date: 'Monday, Dec 10th',
                //       ),
                //       SizedBox(height: 10),
                //       classScheduleWidget(
                //         icon: Icons.location_on,
                //         courseName: 'LANGUAGE',
                //         username: 'Bob',
                //         location: 'Room 202, Science Block',
                //         time: '11:00 AM - 1:00 PM',
                //         date: 'Tuesday, Dec 11th',
                //       ),
                //     ],
                //   ),
                // ),
                //
                // SizedBox(height: 20),
                //
                // // Online Classes at the Bottom
                // Container(
                //   padding: EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.green[50], // Light green for Online
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Online Classes',
                //         style: TextStyle(
                //           color: AppColors.primary,
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       SizedBox(height: 10),
                //       classScheduleWidget(
                //         icon: Icons.video_call,
                //         courseName: 'SCIENCE',
                //         username: 'Siti',
                //         location: 'Zoom Meeting',
                //         time: '2:00 PM - 4:00 PM',
                //         date: 'Wednesday, Dec 12th',
                //       ),
                //     ],
                //   ),
                // ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for displaying a course card (Horizontal Scrolling)
  Widget featureCard({
    required String title,
    required String subtitle,
    required String image,
    // required int totalJoined,
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                height: 140,
                width: double.infinity,
              ),
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(14.0),
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
                // Text(
                //   '$totalJoined Enrolled',
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
    );
  }

  Widget buildCourseCard(Course course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: course),
          ),
        ).then((_) {
          // Refresh the courses when returning from CourseDetailPage
          fetchCourses(); // Ensure to call fetchCourses to refresh the data
        });
      },
      child: Container(
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16.0, right: 4, left: 4),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-Width Placeholder Image (Optional if `course.image` is available)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
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
                    // Course Name with Search Term Highlighting
                    Text(
                      course.name,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (course.desc != null)
                      Text(
                        course.desc!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    // Total Joined, Rating, and Created At
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
                          "${formatDate(course.createdAt.toLocal())}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(flex: 5),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for displaying a popular course card with rating on the right side and Enrolled count next to duration
  Widget popularCourseCard({
    required String author,
    required String title,
    required String image,
    required String description,
    required double rating,
    required String duration,
    required int enrolled, // Added enrolled count
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
                // Author name
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
                    Text(
                      duration,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '$enrolled Enrolled',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Spacer(),
                    // Rating on the right side
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
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

  // Widget for displaying class schedules with username
  Widget classScheduleWidget({
    required IconData icon,
    required String courseName,
    required String username,
    required String location,
    required String time,
    required String date,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$courseName Class',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  username,
                  style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Location: $location',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Time: $time',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Date: $date',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}