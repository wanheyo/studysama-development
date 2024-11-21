import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/course.dart';
import '../../../models/course.dart';
import '../../../models/lesson.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  CourseDetailPage({required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService apiService = ApiService();

  List<Lesson> lessons = [];
  String token = "";
  bool isGrid = false; // Toggle state for grid or list view in lessons


  // final List<Map<String, String>> lessons = [
  //   {"title": "Lesson 1", "desc": "Introduction to Flutter"},
  //   {"title": "Lesson 2", "desc": "State Management Basics"},
  //   {"title": "Lesson 3", "desc": "Building Responsive UIs"},
  //   {"title": "Lesson 4", "desc": "Understanding Navigation"},
  //   {"title": "Lesson 5", "desc": "Using REST APIs"},
  //   // {"title": "Lesson 6", "desc": "Animations in Flutter"},
  // ];


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
    print('course_id:' + course_id.toString() + " | token: " + token);
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
      body: Padding(
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
            const SizedBox(height: 10),
            Text(
              course.desc ?? "No description available.",
              style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Joined: ${course.totalJoined}",
              style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 5),
            Text(
              "Total Visits: ${course.totalVisit}",
              style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 5),
            Text(
              "Average Rating: ${course.averageRating.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 5),
            Text(
              "Status: ${course.status == 1 ? 'Active' : 'Inactive'}",
              style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            Text(
              "Created At: ${course.createdAt.toLocal()}",
              style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat', color: Colors.grey),
            ),
            Text(
              "Updated At: ${course.updatedAt.toLocal()}",
              style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat', color: Colors.grey),
            ),
          ],
        ),
      ),
      // persistentFooterButtons: [
      //   ElevatedButton(
      //     onPressed: () {},
      //     style: ElevatedButton.styleFrom(
      //       padding: const EdgeInsets.symmetric(vertical: 16),
      //     ),
      //     child: Center(
      //       child: const Text(
      //         'Create Course',
      //         style: TextStyle(
      //           fontFamily: 'Montserrat',
      //           fontWeight: FontWeight.bold,
      //           fontSize: 16,
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
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

          // List or Grid View of Lessons
          Expanded(
            child: lessons.isEmpty
                ? Center(
              child: Text(
                "No created lesson found.",
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ) : Padding(
              padding: const EdgeInsets.all(8.0),
              child: !isGrid
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns for grid view
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 2, // Adjust for better layout
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
        ],
      ),

      // Floating Action Button to add a new folder
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a dialog or navigate to a new screen to add a folder
          _showAddFolderDialog(context);
        },
        child: Icon(FontAwesomeIcons.plus, color: Colors.white,),
        backgroundColor: AppColors.primary, // Your custom color
        tooltip: 'Add New Folder',
      ),
    );
  }

// Function to show a dialog for adding a folder
  void _showAddFolderDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Lesson'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Lesson Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Logic to add the folder goes here
                // You can store the new folder in a state or database
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
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
