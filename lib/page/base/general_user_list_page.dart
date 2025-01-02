import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/utils/colors.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../models/user_course.dart';
import '../../models/user_follow.dart';
import '../../services/api_service.dart';
import 'general_profile_page.dart';

class GeneralUserListPage extends StatefulWidget {
  final String title;
  final Course? course;
  final List<UserFollow>? userFollows;
  // final List<User>? users;

  const GeneralUserListPage({Key? key, required this.title, this.course, this.userFollows}) : super(key: key);

  @override
  _GeneralUserListPageState createState() => _GeneralUserListPageState();
}

class _GeneralUserListPageState extends State<GeneralUserListPage> {
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;
  String token = "";

  User? userNow;
  List<UserCourse> userCourses = [];

  bool isLoading = false;

  int listLength = 0;
  bool isFromCourse = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initializeData() async {
    await loadUser();
    await fetchUser();
    if(widget.course != null) {
      await fetchUserCourses();
      isFromCourse = true;
      listLength = userCourses.length;
    } else if(widget.userFollows != null) {
      isFromCourse = false;
      listLength = widget.userFollows!.length;
    }

    // _applyFiltersAndSortCourse();  // Filter created courses
    // await fetchUsers();
    // _applyFiltersAndSortUser();
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
      isLoading = true;
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

  Future<void> fetchUserCourses() async {
    setState(() {
      // context.loaderOverlay.show();
      isLoading = true;
    });

    // print('token: ' + token);
    try {
      final data = await apiService.index_user_course_join(token, widget.course!.id);

      final userMap = {
        for (var file in (data['users'] as List))
          file['id']: User.fromJson(file)
      };

      setState(() {
        userCourses = (data['user_courses'] as List)
            .map((json) {
          final userCourse = UserCourse.fromJson(json);
          userCourse.user = userMap[userCourse.userId];
          return userCourse;
        }).toList();

        //print('course: ' + courses.toString());
      });
    } catch (e) {
      setState(() {
        // errorMessage = e.toString();
        print("Response: " + e.toString());
      });
    } finally {
      // setState(() {
      //   context.loaderOverlay.hide();
        isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : listLength == 0
          ? Center(
        child: Text(
          'No user found'
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: listLength,
        itemBuilder: (context, index) {
          User user;
          if (isFromCourse) {
            user = userCourses[index].user!;
          } else {
            if (widget.title == "follower")
              user = widget.userFollows![index].userFollower!;
            else
              user = widget.userFollows![index].userFollowed!;
          }

          return GestureDetector(
            onTap: () {
              if (userNow!.id == user.id) {
                // widget.onTabChange(3);
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: user.image != null
                            ? DecorationImage(
                          image: NetworkImage(
                              '$domainURL/storage/${user.image!}'),
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (user.bio != null)
                            Text(
                              user.bio!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.userGroup,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 10),
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
    );
  }
}