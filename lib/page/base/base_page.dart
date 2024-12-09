import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studysama/page/base/ai/ai_page.dart';
import 'package:studysama/page/base/my_course/my_course_page.dart';
import 'package:studysama/page/base/home/home_page.dart';
import 'package:studysama/page/base/profile/profile_page.dart';
import 'package:studysama/page/base/profile/setting.dart';
import 'package:studysama/utils/colors.dart';

import 'find/find_page.dart';

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  // Selected index for bottom navigation bar
  int _selectedIndex = 0;

  // List of pages for bottom navigation
  final List<Widget> _pages = [
    HomePage(),
    AiPage(),
    FindPage(),
    MyCoursePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "assets/logo.jpg", // Replace with your logo path
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Text(
              'StudySama',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu),
            onSelected: (value) {
              // Handle menu options
              if (value == 'Profile') {
                // Navigate to Profile
              } else if (value == 'Settings') {
                // Navigate to Settings
              } else if (value == 'Logout') {
                // Handle Logout
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Profile', child: Text('Profile')),
                PopupMenuItem(value: 'Settings', child: Text('Settings')),
                PopupMenuItem(value: 'Logout', child: Text('Logout')),
              ];
            },
          ),
          if (_selectedIndex == 4) // Index for Profile Page
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex], // Display selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.robot),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.magnifyingGlass),
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.scroll),
            label: 'My Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidUser),
            label: 'Profile',
          ),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
      ),
    );
  }
}
