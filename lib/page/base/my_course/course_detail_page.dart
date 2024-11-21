import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/page/base/my_course/manage_course_page.dart';
import '../../../models/course.dart';
import '../../../models/course.dart';
import '../../../models/lesson.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class CourseDetailPage extends StatefulWidget {
  Course course;
  CourseDetailPage({required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  List<Lesson> lessons = [];
  String token = "";
  bool isGrid = false; // Toggle state for grid or list view in lessons

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: About, Lessons, Reviews
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUser();
    fetchLessons();
  }

  @override
  void dispose() {
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
    // if (!_formKey.currentState!.validate()) {
    //   return; // Exit if the form is invalid
    // }

    String name = nameController.text.trim();
    print("Course id: " + widget.course.id.toString() + " | name: " + name);

    // Perform course creation logic here
    setState(() {
      context.loaderOverlay.show();
    });

    try {
      // Call the API
      await apiService.lesson_store(token, name, widget.course.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesson "$name" created successfully',
          ),
        ),
      );
      print("Lesson successa ");
      //widget.onCourseCreated(); // Notify parent to refresh
      Navigator.pop(context); // Navigate back to the previous page

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
                            // fontWeight: FontWeight.bold,
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
              if(widget.course.role_id == 1)
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
                    );
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
              if(widget.course.role_id == 3)
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
                      );
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
              if(widget.course.role_id == null)
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
                      );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFolderDialog(context);
        },
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary,
        tooltip: 'Add New Folder',
      ),
    );
  }

// Function to show a dialog for adding a folder
  void _showAddFolderDialog(BuildContext context) {
    //final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Lesson'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Lesson Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Logic to add the folder goes here
                // You can store the new folder in a state or database
                _createLesson();
                initializeData();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLessonCard(List<Lesson> lessons, int index) {
    return ClipPath(
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
