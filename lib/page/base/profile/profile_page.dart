import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/colors.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs now
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences

    // Navigate back to the login screen (replace this with your LoginPage route)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Top Purple Section
          Container(
            color: AppColors.primary,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Information
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Username
                          Text(
                            '@ayunies',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Handle long names
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          CircleAvatar(
                            radius: screenWidth * 0.08,
                            // Size of the profile image
                            backgroundImage: AssetImage(
                                'assets/profile_image.png'),
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            'BIO:',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Follower and Post Information
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              _buildStatColumn('Post', '10', screenWidth),
                              SizedBox(width: screenWidth * 0.05),
                              _buildStatColumn('Followers', '120', screenWidth),
                              SizedBox(width: screenWidth * 0.05),
                              _buildStatColumn('Following', '120', screenWidth),
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              _buildResponsiveButton(
                                context,
                                'Share Profile',
                                screenWidth,
                                onPressed: () {
                                  // Share profile action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // TabBar Section
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "Created Courses"),
                      Tab(text: "Joined Courses"),
                      Tab(text: "Badge Button"), // Added new tab
                    ],
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: screenWidth * 0.04,
                      color: Colors.white70,
                    ),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                  ),
                ],
              ),
            ),
          ),
          // Tab Bar View Section
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(
                  "Created Courses",
                  "No created courses found.",
                ),
                _buildCoursesTab(
                  "Joined Courses",
                  "No joined courses found.",
                ),
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
            fontSize: screenWidth * 0.04,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
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

  Widget _buildCoursesTab(String title, String emptyMessage) {
    return Center(
      child: Text(
        emptyMessage,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Colors.grey,
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
