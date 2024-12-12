import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/tutor_slot.dart';
import 'package:studysama/models/user_course.dart';
import 'package:studysama/page/base/my_course/manage_course_page.dart';
import '../../../main.dart';
import '../../../models/course.dart';
import '../../../models/course.dart';
import '../../../models/lesson.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import 'lesson_page.dart';

class CourseDetailPage extends StatefulWidget {
  Course course;
  CourseDetailPage({required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  final TextEditingController nameLessonController = TextEditingController();
  final TextEditingController descLessonController = TextEditingController();
  final TextEditingController learnOutcomeLessonController = TextEditingController();

  final TextEditingController nameTutorSlotController = TextEditingController();
  final TextEditingController descTutorSlotController = TextEditingController();
  final TextEditingController dateTutorSlotController = TextEditingController();
  final TextEditingController startTimeTutorSlotController = TextEditingController();
  final TextEditingController endTimeTutorSlotController = TextEditingController();
  final TextEditingController locationTutorSlotController = TextEditingController();

  String selectedType = "Online";
  TimeOfDay? selectedStartTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  List<Lesson> lessons = [];
  List<TutorSlot> tutorSlots = [];

  bool isTutor = false;
  bool isStudent = false;
  UserCourse? userCourse;
  User? tutor;

  String token = "";
  bool isGrid = false; // Toggle state for grid or list view in lessons

  String tutorSlotTab_selectedFilter = 'All'; // Default filter
  String tutorSlotTab_selectedSortOrder = 'Upcoming'; // Default sort order
  List<TutorSlot> filteredTutorSlots = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs: About, Lessons, Tutor Slot, Reviews
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route); // Safe subscription
    }
  }

  Future<void> initializeData() async {
    await loadUser();
    fetchUserCourse();
    fetchLessons();
    fetchTutorSlots();
  }

  @override
  void didPopNext() {
    // Called when returning to this page
    print('Page became active again');
    initializeData(); // Refresh data
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe to avoid memory leaks
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm a");
    return dateFormat.format(date);
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

  Future<void> fetchUserCourse() async {
    setState(() {
      context.loaderOverlay.show();
    });

    int course_id = widget.course.id;
    //print("course_id: " + course_id.toString());
    try {
      final data = await apiService.index_user_course(token, course_id);
      setState(() {
        // Extract boolean values from the response
        isTutor = data['is_user_tutor'] ?? false;
        isStudent = data['is_user_student'] ?? false;
        userCourse = data['user_course'] != null
            ? UserCourse.fromJson(data['user_course'])
            : null;

        tutor = data['tutor'] != null
            ? User.fromJson(data['tutor'])
            : null;
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> fetchLessons() async {
    setState(() {
      context.loaderOverlay.show();
    });

    int course_id = widget.course.id;
    //print("course_id: " + course_id.toString());
    try {
      final data = await apiService.index_lesson_course(token, course_id);
      setState(() {
        lessons = (data['lessons'] as List)
            .map((json) => Lesson.fromJson(json))
            .toList();
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _createLesson() async {
    String name = nameLessonController.text.trim();
    String description = descLessonController.text.trim();
    String learningOutcome = learnOutcomeLessonController.text.trim();

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.lesson_store(token, name, learningOutcome, description, widget.course.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesson "$name" created successfully',
          ),
        ),
      );
      print("Lesson success");
      //widget.onCourseCreated(); // Notify parent to refresh
      // Navigator.pop(context); // Navigate back to the previous page

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lesson creation failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> updateJoinOrLeave(int status) async {
    setState(() {
      context.loaderOverlay.show();
    });

    int course_id = widget.course.id;
    //print("course_id: " + course_id.toString());
    try {
      final data = await apiService.update_user_course(token, course_id, status);

      String message;
      if(status == 0)
        message = "Leaving course " + widget.course.name + "...";
      else
        message = "Joining course " + widget.course.name + ".";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
      initializeData();
      print("Update user course successa ");

      setState(() {
        // lessons = (data['lessons'] as List)
        //     .map((json) => Lesson.fromJson(json))
        //     .toList();
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> fetchTutorSlots() async {
    setState(() {
      context.loaderOverlay.show();
    });

    int course_id = widget.course.id;
    //print("course_id: " + course_id.toString());
    try {
      final data = await apiService.index_tutorslot_course(token, course_id);
      setState(() {
        tutorSlots = (data['tutorslots'] as List)
            .map((json) => TutorSlot.fromJson(json))
            .toList();

        _applyFiltersAndSort();
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _createTutorSlot() async {
    String name = nameTutorSlotController.text.trim();
    String description = descTutorSlotController.text.trim();
    String learningOutcome = learnOutcomeLessonController.text.trim();
    String location = locationTutorSlotController.text.trim();
    String type = selectedType;

    // Parse date and time from the controllers
    DateTime? date;
    DateTime? startTime;
    DateTime? endTime;

    try {
      // Combine date with time to create full ISO 8601 strings
      String fullStartTime = '${dateTutorSlotController.text.trim()}T${startTimeTutorSlotController.text.trim()}:00';
      String fullEndTime = '${dateTutorSlotController.text.trim()}T${endTimeTutorSlotController.text.trim()}:00';

      date = DateTime.parse(dateTutorSlotController.text.trim());
      startTime = DateTime.parse(fullStartTime); // Parse the combined start time
      endTime = DateTime.parse(fullEndTime); // Parse the combined end time
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date or time format. Please use ISO 8601 format.')),
      );
      return; // Exit if parsing fails
    }

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.tutorslot_store(token, name, learningOutcome, description, widget.course.id, type, date, startTime, endTime, location,);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tutor slot "$name" created successfully',
          ),
        ),
      );
      print("Tutor slot success");
      // Optionally notify parent to refresh or navigate back
      // widget.onCourseCreated();
      // Navigator.pop(context);

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutor slot creation failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _updateTutorSlot(TutorSlot tutorSlot) async {
    String name = nameTutorSlotController.text.trim();
    String description = descTutorSlotController.text.trim();
    String location = locationTutorSlotController.text.trim();
    String type = selectedType;

    // Parse date and time from the controllers
    DateTime? date;
    DateTime? startTime;
    DateTime? endTime;
    int status = 1;

    try {
      // Combine date with time to create full ISO 8601 strings
      String fullStartTime = '${dateTutorSlotController.text.trim()}T${startTimeTutorSlotController.text.trim()}:00';
      String fullEndTime = '${dateTutorSlotController.text.trim()}T${endTimeTutorSlotController.text.trim()}:00';

      date = DateTime.parse(dateTutorSlotController.text.trim());
      startTime = DateTime.parse(fullStartTime); // Parse the combined start time
      endTime = DateTime.parse(fullEndTime); // Parse the combined end time
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date or time format. Please use ISO 8601 format.')),
      );
      return; // Exit if parsing fails
    }

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.tutorslot_update(token, tutorSlot.id, name, description, type, date, startTime, endTime, location, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tutor slot updated successfully',
          ),
        ),
      );

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutor slot update failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  Future<void> _deleteTutorSlot(TutorSlot tutorSlot) async {
    String name = "";
    String description = "";
    String location = locationTutorSlotController.text.trim();
    String type = selectedType;

    // Parse date and time from the controllers
    DateTime? date;
    DateTime? startTime;
    DateTime? endTime;
    int status = 0;

    try {
      // Combine date with time to create full ISO 8601 strings
      String fullStartTime = '${dateTutorSlotController.text.trim()}T${startTimeTutorSlotController.text.trim()}:00';
      String fullEndTime = '${dateTutorSlotController.text.trim()}T${endTimeTutorSlotController.text.trim()}:00';

      date = DateTime.parse(dateTutorSlotController.text.trim());
      startTime = DateTime.parse(fullStartTime); // Parse the combined start time
      endTime = DateTime.parse(fullEndTime); // Parse the combined end time
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date or time format. Please use ISO 8601 format.')),
      );
      return; // Exit if parsing fails
    }

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.tutorslot_update(token, tutorSlot.id, name, description, type, date, startTime, endTime, location, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tutor slot deleted successfully',
          ),
        ),
      );

    } catch (e) {
      // Extract meaningful error messages if available
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutor slot update failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      setState(() {
        context.loaderOverlay.hide();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Course",
          // style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isTutor)
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: PopupMenuButton<String>(
                icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Colors.white),
                onSelected: (String value) async {
                  switch (value) {
                    case 'Manage Course':
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCoursePage(
                            course: widget.course,
                            onCourseUpdated: (updatedCourse) {
                              setState(() {
                                widget.course = updatedCourse; // Update the course data
                                initializeData(); // Refresh lessons or other related data
                              });
                            },
                          ),
                        ),
                      ).then((_) {
                        // Call initializeData on returning to this page
                        initializeData();
                      });
                      break;
                    case 'Add Lesson':
                      _showAddLessonBottomSheet(context);
                      break;
                    case 'Hint':
                    // _showHint();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Manage Course',
                      child: Text('Manage Course'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Add Lesson',
                      child: Text('Add Lesson'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Hint',
                      child: Text('Hint'),
                    ),
                  ];
                },
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Lessons'),
            Tab(text: 'Tutor Slot'),
            Tab(text: 'Reviews'),
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
      body: LoaderOverlay(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(widget.course),
            _buildLessonsTab(),
            _buildTutorSlotTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
    );
  }

  // About Tab
  Widget _buildAboutTab(Course course) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // First Card: Title, Description
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0, // No shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
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
                        const SizedBox(height: 30),
                        const Text(
                          "Description:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          course.desc ?? "No description available.",
                          style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Second Card: Total Joined, Average Rating
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0, // No shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Joined and Average Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title-value pairs
                          children: [
                            // Total Joined Column
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Total Joined",
                                  style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${course.totalJoined}",
                                  style: const TextStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // Average Rating Column
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Average Rating",
                                  style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${course.averageRating.toStringAsFixed(1)}",
                                  style: const TextStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Third Card: Status, Created At, Updated At
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0, // No shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Section
                        Row(
                          children: [
                            Text(
                              "Status: ${course.status == 1 ? 'Public' : course.status == 2 ? 'Private' : 'Deleted'}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                color: course.status == 0 ? Colors.red : Colors.black, // Red for deleted, black for others
                              ),
                            ),
                            if (course.status == 1) // Show the lock icon only if the status is Private
                              const Padding(
                                padding: EdgeInsets.only(left: 5.0), // Optional: adds some space between text and icon
                                child: Icon(
                                  FontAwesomeIcons.globe,
                                  size: 14, // Adjust size as needed
                                  color: Colors.grey, // You can change the color as per your need
                                ),
                              ),
                            if (course.status == 2) // Show the lock icon only if the status is Private
                              const Padding(
                                padding: EdgeInsets.only(left: 5.0), // Optional: adds some space between text and icon
                                child: Icon(
                                  FontAwesomeIcons.lock,
                                  size: 14, // Adjust size as needed
                                  color: Colors.grey, // You can change the color as per your need
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Created At and Updated At Sections
                        Text(
                          "Created At: ${formatDate(course.createdAt.toLocal())}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Updated At: ${formatDate(course.updatedAt.toLocal())}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Fourth Card: Tutor/Creator
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0, // No shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Section
                        Row(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tutor/Creator: ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    tutor?.name ?? "null",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Card(
                                    color: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      child: Text(
                                        'Tutor',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Fifth Card: Manage Course Button
              if(isTutor)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCoursePage(
                            course: widget.course,
                            onCourseUpdated: (updatedCourse) {
                              setState(() {
                                widget.course = updatedCourse; // Update the course data
                                initializeData(); // Refresh lessons or other related data
                              });
                            },
                          ),
                        ),
                      ).then((_) {
                        // Call initializeData on returning to this page
                        initializeData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Manage Course"),
                  ),
                ),
              if(isStudent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      updateJoinOrLeave(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Leave Course"),
                  ),
                ),
              if(!isTutor && !isStudent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      updateJoinOrLeave(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Join Course"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Lessons Tab
  Widget _buildLessonsTab() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: initializeData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lesson",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 10),
              // Toggle Button for Switching Layouts
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Grid: ",
                    style: TextStyle(
                      fontSize: 16,
                      // fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  IconButton(
                    icon: Icon(!isGrid ? FontAwesomeIcons.list : FontAwesomeIcons.gripVertical),
                    onPressed: () {
                      setState(() {
                        isGrid = !isGrid; // Toggle the layout
                      });
                    },
                  ),
                ],
              ),

              // Lessons List/Grid
              Expanded(
                child: lessons.isEmpty
                    ? Center(
                  child: Text(
                    "No created lesson found.",
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                )
                    : !isGrid
                        ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        return _buildLessonCard(lessons, index);
                      },
                    )
                        : ListView.builder(
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        return _buildLessonCard(lessons, index);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button to add a new folder
      floatingActionButton: isTutor ?
      FloatingActionButton(
        onPressed: () {
          _showAddLessonBottomSheet(context);
        },
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary,
        tooltip: 'Add New Folder',
      ): null,
    );
  }

  // Function to show a dialog for adding a folder
  void _showAddLessonBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16.0),
                  const Center(
                    child: Text(
                      "Add New Lesson",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Lesson Name
                  TextFormField(
                    controller: nameLessonController,
                    decoration: const InputDecoration(
                      labelText: 'Lesson Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter lesson name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a lesson name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Description
                  TextFormField(
                    controller: descLessonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Learning Outcome
                  TextFormField(
                    controller: learnOutcomeLessonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Learning Outcome (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Clear all fields before closing
                          nameLessonController.clear();
                          descLessonController.clear();
                          learnOutcomeLessonController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Proceed with lesson creation logic
                            _createLesson();
                            initializeData();
                            Navigator.pop(context); // Close the bottom sheet
                          }
                        },
                        child: const Text("Add Lesson"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonCard(List<Lesson> lessons, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to the LessonResourcePage with the lesson's details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonPage(lesson: lessons[index], course: widget.course, isTutor: isTutor, userCourse: userCourse),
          ),
        );
      },
      child: ClipPath(
        clipper: FolderClipper(), // Custom clipper for folder shape
        child: Card(
          elevation: 3,
          //color: AppColors.accent, // Folder-like color
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title with Ellipsis
                Text(
                  lessons[index].name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),

                // Description with Ellipsis
                Text(
                  lessons[index].description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tutor Slot Tab
  Widget _buildTutorSlotTab() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: initializeData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resources Section Header
              const Text(
                "Tutor Slot",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 10),
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
                          _buildSegmentedButton('All'),
                          const SizedBox(width: 8),
                          _buildSegmentedButton('Online'),
                          const SizedBox(width: 8),
                          _buildSegmentedButton('Physical'),
                        ],
                      ),
                    ),
                  ),
                  // Add space between segmented buttons and dropdown
                  const SizedBox(width: 16), // Adjust the width as needed
                  // Sort Button fixed on the right
                  DropdownButton<String>(
                    value: tutorSlotTab_selectedSortOrder,
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      setState(() {
                        tutorSlotTab_selectedSortOrder = newValue!;
                        _applyFiltersAndSort(); // Call the filtering and sorting function
                      });
                    },
                    items: <String>['Upcoming', 'Ended']
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
              // Display the tutor slots based on selected filter
              Expanded(
                child: tutorSlots.isEmpty
                    ? const Center(
                  child: Text(
                    "No created tutor slot found.",
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                ) :
                ListView.builder(
                  itemCount: filteredTutorSlots.length, // Use filtered list
                  itemBuilder: (context, index) {
                    final slot = filteredTutorSlots[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          classScheduleWidget(
                            icon: slot.type == 'Physical'
                                ? FontAwesomeIcons.locationDot
                                : FontAwesomeIcons.video,
                            name: slot.name,
                            username: "Test",
                            location: slot.location,
                            time: "${DateFormat.jm().format(slot.startTime.toLocal())} - ${DateFormat.jm().format(slot.endTime.toLocal())}",
                            startTime: slot.startTime,
                            endTime: slot.endTime,
                            date: slot.date,
                            type: slot.type,
                            tutorSlot: slot,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button to add a new tutor slot
      floatingActionButton: isTutor ?
      FloatingActionButton(
        onPressed: () {
          _showAddTutorSlotBottomSheet(context);
        },
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary,
        tooltip: 'Add New Tutor Slot',
      ): null
    );
  }

// Build segmented button
  Widget _buildSegmentedButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          tutorSlotTab_selectedFilter = label; // Update the selected filter
          _applyFiltersAndSort(); // Apply filters and sort
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: tutorSlotTab_selectedFilter == label ? AppColors.primary : AppColors.accent,
      ),
      child: Text(label),
    );
  }

// Apply filtering and sorting
  void _applyFiltersAndSort() {
    // Start with the original tutor slots list
    List<TutorSlot> tempTutorSlots = List.from(tutorSlots);

    if (tutorSlotTab_selectedFilter == 'Online') {
      tempTutorSlots = tempTutorSlots.where((slot) => slot.type == 'Online').toList();
    } else if (tutorSlotTab_selectedFilter == 'Physical') {
      tempTutorSlots = tempTutorSlots.where((slot) => slot.type == 'Physical').toList();
    }

    // // Apply sorting
    // if (tutorSlotTab_selectedSortOrder == 'Newest') {
    //   tempTutorSlots.sort((a, b) => b.date.toLocal().compareTo(a.date.toLocal()));
    // } else if (tutorSlotTab_selectedSortOrder == 'Oldest') {
    //   tempTutorSlots.sort((a, b) => a.date.toLocal().compareTo(b.date.toLocal()));
    // }

    // Apply sorting
    if (tutorSlotTab_selectedSortOrder == 'Upcoming') {
      tempTutorSlots = tempTutorSlots.where((slot) => DateTime(slot.date.toLocal().year, slot.date.toLocal().month, slot.date.toLocal().day, slot.endTime.toLocal().hour, slot.endTime.toLocal().minute).isAfter(DateTime.now().toLocal())).toList();
      tempTutorSlots.sort((a, b) => DateTime(a.date.toLocal().year, a.date.toLocal().month, a.date.toLocal().day, a.endTime.toLocal().hour, a.endTime.toLocal().minute).compareTo(DateTime(b.date.toLocal().year, b.date.toLocal().month, b.date.toLocal().day, b.endTime.toLocal().hour, b.endTime.toLocal().minute)));
    } else if (tutorSlotTab_selectedSortOrder == 'Ended') {
      tempTutorSlots = tempTutorSlots.where((slot) => DateTime(slot.date.toLocal().year, slot.date.toLocal().month, slot.date.toLocal().day, slot.endTime.toLocal().hour, slot.endTime.toLocal().minute).isBefore(DateTime.now().toLocal())).toList();
      tempTutorSlots.sort((a, b) => DateTime(b.date.toLocal().year, b.date.toLocal().month, b.date.toLocal().day, b.endTime.toLocal().hour, b.endTime.toLocal().minute).compareTo(DateTime(a.date.toLocal().year, a.date.toLocal().month, a.date.toLocal().day, a.endTime.toLocal().hour, a.endTime.toLocal().minute)));
    }

    // Update the filteredTutorSlots list
    setState(() {
      filteredTutorSlots = tempTutorSlots;
    });
  }

  // Function to show a dialog for adding a folder
  void _showAddTutorSlotBottomSheet(BuildContext context) {
    String? startTimeErrorMessage; // Error message for invalid Start Time
    String? endTimeErrorMessage; // Error message for invalid End Time

    // Helper function to format TimeOfDay in 24-hour format
    String formatTimeOfDay24Hour(TimeOfDay time) {
      final hours = time.hour.toString().padLeft(2, '0');
      final minutes = time.minute.toString().padLeft(2, '0');
      return "$hours:$minutes";
    }

    // Helper to parse selected Start Time from TextField
    TimeOfDay? selectedStartTimeFromText(String TimeController) {
      // print("startTime: " + startTimeTutorSlotController.text);
      if (TimeController.isNotEmpty) {
        final parts = TimeController.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(" ")[0]);
        return TimeOfDay(hour: hour, minute: minute);
      }
      return null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16.0),
                  const Center(
                    child: Text(
                      "Add New Tutor Slot",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Lesson Name
                  TextFormField(
                    controller: nameTutorSlotController,
                    decoration: const InputDecoration(
                      labelText: 'Tutor Slot Title',
                      border: OutlineInputBorder(),
                      hintText: 'Enter tutor slot title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tutor slot name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Description
                  TextFormField(
                    controller: descTutorSlotController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Type (Physical/Online)
                  DropdownButtonFormField<String>(
                    value: selectedType, // This must match one of the item values or be null
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Online',
                        child: Text('Online'),
                      ),
                      DropdownMenuItem(
                        value: 'Physical',
                        child: Text('Physical'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!; // Ensure selectedType is updated
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a tutor slot type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Date Picker
                  TextFormField(
                    controller: dateTutorSlotController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      hintText: 'Select date',
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(), // Prevent past dates
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dateTutorSlotController.text = pickedDate.toLocal().toString().split(' ')[0];
                          // Clear times if the date changes
                          startTimeTutorSlotController.clear();
                          endTimeTutorSlotController.clear();
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Start Time Picker
                  StatefulBuilder(
                    builder: (context, setFieldState) {
                      return TextFormField(
                        controller: startTimeTutorSlotController,
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          hintText: 'Select start time',
                          errorText: startTimeErrorMessage,
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime now = DateTime.now();
                          bool isToday = dateTutorSlotController.text == now.toLocal().toString().split(' ')[0];

                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: isToday
                                ? TimeOfDay.fromDateTime(now.add(Duration(minutes: 1))) // Suggest time slightly ahead of current time
                                : TimeOfDay(hour: 0, minute: 0), // Default to midnight if not today
                          );

                          if (pickedTime != null) {
                            if (isToday) {
                              // Ensure the time is not in the past
                              DateTime selectedDateTime = DateTime(now.year, now.month, now.day,
                                  pickedTime.hour, pickedTime.minute);
                              if (selectedDateTime.isBefore(now)) {
                                setFieldState(() {
                                  startTimeTutorSlotController.clear();
                                  endTimeTutorSlotController.clear(); // Clear end time if start time changes
                                  startTimeErrorMessage = 'Start time must not be in the past';
                                });
                                return;
                              }
                            }
                            setState(() {
                              // startTimeTutorSlotController.text = pickedTime.format(context);
                              startTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeTutorSlotController.clear(); // Clear end time if start time changes
                              startTimeErrorMessage = null; // Clear error message
                              endTimeErrorMessage = null; // Clear error message
                            });

                            setFieldState(() {
                              startTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeTutorSlotController.clear(); // Clear end time if start time changes
                              startTimeErrorMessage = null; // Clear error message
                              endTimeErrorMessage = null; // Clear error message
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a start time';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // End Time Picker
                  StatefulBuilder(
                    builder: (context, setFieldState) {
                      return TextFormField(
                        controller: endTimeTutorSlotController,
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          border: const OutlineInputBorder(),
                          hintText: 'Select end time',
                          errorText: endTimeErrorMessage, // Dynamically updated error message
                        ),
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTimeFromText(startTimeTutorSlotController.text) ?? TimeOfDay(hour: 0, minute: 0),
                          );

                          if (pickedTime != null) {
                            TimeOfDay? startTime =
                            selectedStartTimeFromText(startTimeTutorSlotController.text);

                            print("startTime: " + startTime.toString());
                            print("endTime: " + pickedTime.toString());
                            if (startTime != null &&
                                (pickedTime.hour < startTime.hour ||
                                    (pickedTime.hour == startTime.hour &&
                                        pickedTime.minute <= startTime.minute))) {
                              setFieldState(() {
                                endTimeTutorSlotController.clear();
                                endTimeErrorMessage = 'End time must be later than start time.';
                              });
                              return;
                            }

                            setState(() {
                              endTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeErrorMessage = null; // Clear error message
                            });

                            setFieldState(() {
                              endTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeErrorMessage = null; // Clear error message
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an end time';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Location
                  TextFormField(
                    controller: locationTutorSlotController,
                    decoration: const InputDecoration(
                        labelText: "Platform @ Location",
                      border: OutlineInputBorder(),
                        hintText: "Enter Platform @ Location",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location or platform';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Clear all fields before closing
                          nameTutorSlotController.clear();
                          descTutorSlotController.clear();
                          locationTutorSlotController.clear();
                          dateTutorSlotController.clear();
                          startTimeTutorSlotController.clear();
                          endTimeTutorSlotController.clear();
                          selectedType = "Online";
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Proceed with lesson creation logic
                            _createTutorSlot();
                            Navigator.pop(context); // Close the bottom sheet


                            setState(() {
                              // Clear all fields before closing
                              nameTutorSlotController.clear();
                              descTutorSlotController.clear();
                              locationTutorSlotController.clear();
                              dateTutorSlotController.clear();
                              startTimeTutorSlotController.clear();
                              endTimeTutorSlotController.clear();
                              selectedType = "Online";
                              initializeData();
                            });
                          }
                        },
                        child: const Text("Add Tutor Slot"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget classScheduleWidget({
    required IconData icon,
    required String name,
    required String username,
    required String location,
    required String time,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime date,
    required String type,
    required TutorSlot tutorSlot,
  }) {
    // Parse the date and time to create a DateTime object
    DateTime classStartTime = DateTime(
      date.toLocal().year,
      date.toLocal().month,
      date.toLocal().day,
      startTime.toLocal().hour,
      startTime.toLocal().minute,
    );

    DateTime classEndTime = DateTime(
      date.toLocal().year,
      date.toLocal().month,
      date.toLocal().day,
      endTime.toLocal().hour,
      endTime.toLocal().minute,
    );

    // DateTime classDateTime = DateTime.parse('$date');
    DateTime now = DateTime.now();

    // Determine if the class is ongoing or in the past
    bool isPast = classEndTime.isBefore(now);
    bool isOngoing = classEndTime.isAfter(now) && classStartTime.isBefore(now);

    print("Time now: " + now.toString());
    print("Start time: " + startTime.toString());
    print("classEndTime: " + classEndTime.toString());
    print("Tutor Date: " + tutorSlot.date.toLocal().toString());

    Color cardColor;

    switch (type) {
      case "Online":
        cardColor = Colors.blue[300]!;
        break;
      case "Physical":
        cardColor = Colors.red[300]!;
        break;
      default:
        cardColor = Colors.grey[300]!;
    }

    return GestureDetector(
      child: Card(
        color: isPast ? Colors.grey[300] : Colors.white, // Gray out if past
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Card(
                          color: cardColor,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          child: Builder(
                              builder: (context) {
                                if (isOngoing)
                                  return Card(
                                    color: Colors.green,
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                      child: Text(
                                        'Live',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                if(isPast)
                                  return Card(
                                    color: Colors.grey[500]!,
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                      child: Text(
                                        'Ended',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                return Card(
                                  color: Colors.green[200]!,
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                    child: Text(
                                      'Upcoming',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Location: $location',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Date: ${DateFormat('dd/MM/yyyy, EEEE').format(tutorSlot.date.toLocal())}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Time: $time',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showClassScheduleDetail(context, tutorSlot, icon, isPast, isOngoing);
      },
    );
  }

  void _showClassScheduleDetail(BuildContext context, TutorSlot tutorSlot, IconData tutorSlotType, bool isPast, bool isOngoing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gray swipe indicator at the top
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              // Class schedule details
              ListTile(
                // contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Row(
                  children: [
                    Icon(tutorSlotType, color: AppColors.primary, size: 24),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutorSlot.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Card(
                                color: Colors.blue[300]!,
                                margin: const EdgeInsets.only(bottom: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                  child: Text(
                                    'Tutor Slot',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                child: Builder(
                                  builder: (context) {
                                    if (isOngoing)
                                      return Card(
                                        color: Colors.green,
                                        margin: const EdgeInsets.only(bottom: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                          child: Text(
                                            'Live',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    if(isPast)
                                      return Card(
                                        color: Colors.grey[500]!,
                                        margin: const EdgeInsets.only(bottom: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                          child: Text(
                                            'Ended',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    return Card(
                                      color: Colors.green[200]!,
                                      margin: const EdgeInsets.only(bottom: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                        child: Text(
                                          'Upcoming',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Location: ${tutorSlot.location}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Date: ${DateFormat('dd/MM/yyyy, EEEE').format(tutorSlot.date.toLocal())}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Time: ${DateFormat.jm().format(tutorSlot.startTime.toLocal())} - ${DateFormat.jm().format(tutorSlot.endTime.toLocal())}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Description: ${tutorSlot.desc ?? 'No description provided.'}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons at the bottom-right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isTutor && !isPast && !isOngoing)
                    ElevatedButton(
                      onPressed: () {
                        _showEditTutorSlotBottomSheet(context, tutorSlot);
                      },
                      child: const Text('Edit'),
                    ),
                  IconButton(
                    onPressed: () {
                      // Copy class schedule details to clipboard
                      Clipboard.setData(ClipboardData(text: tutorSlot.desc ?? 'No description provided.'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tutor slot details copied to clipboard')),
                      );
                    },
                    icon: const Icon(FontAwesomeIcons.copy, size: 20,),
                    tooltip: 'Copy Tutor Slot Details',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show a dialog for adding a folder
  void _showEditTutorSlotBottomSheet(BuildContext context, TutorSlot tutorSlot) {
    String? startTimeErrorMessage; // Error message for invalid Start Time
    String? endTimeErrorMessage; // Error message for invalid End Time


    // Helper function to format TimeOfDay in 24-hour format
    String formatTimeOfDay24Hour(TimeOfDay time) {
      final hours = time.hour.toString().padLeft(2, '0');
      final minutes = time.minute.toString().padLeft(2, '0');
      return "$hours:$minutes";
    }

    // Helper to parse selected Start Time from TextField
    TimeOfDay? selectedStartTimeFromText(String TimeController) {
      // print("startTime: " + startTimeTutorSlotController.text);
      if (TimeController.isNotEmpty) {
        final parts = TimeController.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(" ")[0]);
        return TimeOfDay(hour: hour, minute: minute);
      }
      return null;
    }

    nameTutorSlotController.text = tutorSlot.name;
    descTutorSlotController.text = tutorSlot.desc ?? "";
    selectedType = tutorSlot.type;
    dateTutorSlotController.text = tutorSlot.date.toLocal().toString().split(' ')[0];
    startTimeTutorSlotController.text = formatTimeOfDay24Hour(TimeOfDay.fromDateTime(tutorSlot.startTime.toLocal()));
    endTimeTutorSlotController.text = formatTimeOfDay24Hour(TimeOfDay.fromDateTime(tutorSlot.endTime.toLocal()));
    locationTutorSlotController.text = tutorSlot.location;

    print('start time: ' + tutorSlot.endTime.toLocal().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16.0),
                  const Center(
                    child: Text(
                      "Edit Tutor Slot",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Lesson Name
                  TextFormField(
                    controller: nameTutorSlotController,
                    decoration: const InputDecoration(
                      labelText: 'Tutor Slot Title',
                      border: OutlineInputBorder(),
                      hintText: 'Enter tutor slot title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tutor slot name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Description
                  TextFormField(
                    controller: descTutorSlotController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Type (Physical/Online)
                  DropdownButtonFormField<String>(
                    value: selectedType, // This must match one of the item values or be null
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Online',
                        child: Text('Online'),
                      ),
                      DropdownMenuItem(
                        value: 'Physical',
                        child: Text('Physical'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!; // Ensure selectedType is updated
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a tutor slot type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Date Picker
                  TextFormField(
                    controller: dateTutorSlotController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      hintText: 'Select date',
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(), // Prevent past dates
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dateTutorSlotController.text = pickedDate.toLocal().toString().split(' ')[0];
                          // Clear times if the date changes
                          startTimeTutorSlotController.clear();
                          endTimeTutorSlotController.clear();
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Start Time Picker
                  StatefulBuilder(
                    builder: (context, setFieldState) {
                      return TextFormField(
                        controller: startTimeTutorSlotController,
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          hintText: 'Select start time',
                          errorText: startTimeErrorMessage,
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime now = DateTime.now();
                          bool isToday = dateTutorSlotController.text == now.toLocal().toString().split(' ')[0];

                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: isToday
                                ? TimeOfDay.fromDateTime(now.add(Duration(minutes: 1))) // Suggest time slightly ahead of current time
                                : TimeOfDay(hour: 0, minute: 0), // Default to midnight if not today
                          );

                          if (pickedTime != null) {
                            if (isToday) {
                              // Ensure the time is not in the past
                              DateTime selectedDateTime = DateTime(now.year, now.month, now.day,
                                  pickedTime.hour, pickedTime.minute);
                              if (selectedDateTime.isBefore(now)) {
                                setFieldState(() {
                                  startTimeTutorSlotController.clear();
                                  endTimeTutorSlotController.clear(); // Clear end time if start time changes
                                  startTimeErrorMessage = 'Start time must not be in the past';
                                });
                                return;
                              }
                            }
                            setState(() {
                              // startTimeTutorSlotController.text = pickedTime.format(context);
                              startTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeTutorSlotController.clear(); // Clear end time if start time changes
                              startTimeErrorMessage = null; // Clear error message
                              endTimeErrorMessage = null; // Clear error message
                            });

                            setFieldState(() {
                              startTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeTutorSlotController.clear(); // Clear end time if start time changes
                              startTimeErrorMessage = null; // Clear error message
                              endTimeErrorMessage = null; // Clear error message
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a start time';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // End Time Picker
                  StatefulBuilder(
                    builder: (context, setFieldState) {
                      return TextFormField(
                        controller: endTimeTutorSlotController,
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          border: const OutlineInputBorder(),
                          hintText: 'Select end time',
                          errorText: endTimeErrorMessage, // Dynamically updated error message
                        ),
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTimeFromText(startTimeTutorSlotController.text) ?? TimeOfDay(hour: 0, minute: 0),
                          );

                          if (pickedTime != null) {
                            TimeOfDay? startTime =
                            selectedStartTimeFromText(startTimeTutorSlotController.text);

                            print("startTime: " + startTime.toString());
                            print("endTime: " + pickedTime.toString());
                            if (startTime != null &&
                                (pickedTime.hour < startTime.hour ||
                                    (pickedTime.hour == startTime.hour &&
                                        pickedTime.minute <= startTime.minute))) {
                              setFieldState(() {
                                endTimeTutorSlotController.clear();
                                endTimeErrorMessage = 'End time must be later than start time.';
                              });
                              return;
                            }

                            setState(() {
                              endTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeErrorMessage = null; // Clear error message
                            });

                            setFieldState(() {
                              endTimeTutorSlotController.text = formatTimeOfDay24Hour(pickedTime);
                              endTimeErrorMessage = null; // Clear error message
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an end time';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Location
                  TextFormField(
                    controller: locationTutorSlotController,
                    decoration: const InputDecoration(
                      labelText: "Platform @ Location",
                      border: OutlineInputBorder(),
                      hintText: "Enter Platform @ Location",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location or platform';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Clear all fields before closing
                          nameTutorSlotController.clear();
                          descTutorSlotController.clear();
                          locationTutorSlotController.clear();
                          dateTutorSlotController.clear();
                          startTimeTutorSlotController.clear();
                          endTimeTutorSlotController.clear();
                          selectedType = "Online";
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          // padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          _showDeleteTutorSlotConfirmationDialog(tutorSlot);
                        },
                        child: const Text("Delete"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Proceed with lesson creation logic
                            _updateTutorSlot(tutorSlot);
                            Navigator.pop(context);
                            Navigator.pop(context);

                            setState(() {
                              // Clear all fields before closing
                              nameTutorSlotController.clear();
                              descTutorSlotController.clear();
                              locationTutorSlotController.clear();
                              dateTutorSlotController.clear();
                              startTimeTutorSlotController.clear();
                              endTimeTutorSlotController.clear();
                              selectedType = "Online";
                              initializeData();
                            });

                          }
                        },
                        child: const Text("Edit Tutor Slot"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteTutorSlotConfirmationDialog(TutorSlot tutorSlot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the dialog size wrap its content
            children: [
              const Text('Are you sure you want to delete this tutor slot? This action cannot be undone.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteTutorSlot(tutorSlot); // Call the delete course function
                Navigator.pop(context); // Close the bottom sheet
                Navigator.pop(context); // Close the bottom sheet (tutorslot detail)
                Navigator.pop(context); // Close the bottom sheet (tutorslot detail)
                // Clear all fields before closing

                setState(() {
                  nameTutorSlotController.clear();
                  descTutorSlotController.clear();
                  locationTutorSlotController.clear();
                  dateTutorSlotController.clear();
                  startTimeTutorSlotController.clear();
                  endTimeTutorSlotController.clear();
                  selectedType = "Online";
                  initializeData();
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
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

class FolderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Starting at the top-left corner
    //path.moveTo(0, size.height * 0.2); // Start at the "tab"
    //path.lineTo(size.width * 0.2, size.height * 0.2); // Horizontal "tab" edge
    path.lineTo(size.width * 0.3, 0); // Slanted edge of the "tab"
    path.lineTo(size.width * 0.7, 0); // Top of the "tab"
    path.lineTo(size.width * 0.8, size.height * 0.2); // Slanted edge of the "tab"
    path.lineTo(size.width, size.height * 0.2); // End of the "tab"

    // Draw the rest of the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}