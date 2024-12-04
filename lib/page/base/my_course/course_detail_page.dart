import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/page/base/my_course/manage_course_page.dart';
import '../../../main.dart';
import '../../../models/course.dart';
import '../../../models/course.dart';
import '../../../models/lesson.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController learnOutcomeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  List<Lesson> lessons = [];
  bool isTutor = false;
  bool isStudent = false;
  String token = "";
  bool isGrid = false; // Toggle state for grid or list view in lessons


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: About, Lessons, Reviews
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
    String name = nameController.text.trim();
    String description = descController.text.trim();
    String learningOutcome = learnOutcomeController.text.trim();

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
      print("Lesson successa ");
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
            Tab(text: 'About'),
            Tab(text: 'Lessons'),
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

              // Fourth Card: Manage Course Button
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
      body: Column(
        children: [
          // Toggle Button for Switching Layouts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
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
          ),

          // Lessons List/Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: initializeData,
              child: lessons.isEmpty
                  ? Center(
                child: Text(
                  "No created lesson found.",
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: !isGrid
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
            ),
          ),
        ],
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
                    controller: nameController,
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
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Learning Outcome
                  TextFormField(
                    controller: learnOutcomeController,
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
                          nameController.clear();
                          descController.clear();
                          learnOutcomeController.clear();
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
            builder: (context) => LessonPage(lesson: lessons[index], course: widget.course, isTutor: isTutor,),
          ),
        );
      },
      child: ClipPath(
        clipper: FolderClipper(), // Custom clipper for folder shape
        child: Card(
          elevation: 4,
          //color: AppColors.accent, // Folder-like color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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