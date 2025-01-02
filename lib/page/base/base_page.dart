import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studysama/page/auth/start_page.dart';
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

  late List<Widget> _pages; // Declare without initialization

  DateTime? currentBackPressTime;
  bool canPopNow = false;
  int requiredSeconds = 2;

  @override
  void initState() {
    super.initState();
    // Initialize the _pages list here
    _pages = [
      HomePage(onTabChange: _onItemTapped),
      AiPage(),
      FindPage(onTabChange: _onItemTapped), // Pass the callback here
      MyCoursePage(),
      ProfilePage(),
    ];
  }

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
              'assets/SS_Header_Transparent_16-9.png',
              height: 100, // You can adjust the height
              // fit: BoxFit.cover,
              // height: 140,
              // width: double.infinity,
            ),
            // SizedBox(width: 10),
            // Text(
            //   'StudySama',
            //   style: TextStyle(
            //     fontFamily: 'Montserrat',
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: _selectedIndex == 0 ?
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ), // Rounded corners
        ) : null,
        actions: [
          // PopupMenuButton<String>(
          //   icon: Icon(Icons.menu),
          //   onSelected: (value) {
          //     // Handle menu options
          //     if (value == 'Profile') {
          //       // Navigate to Profile
          //     } else if (value == 'Settings') {
          //       // Navigate to Settings
          //     } else if (value == 'Logout') {
          //       // Handle Logout
          //     }
          //   },
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       PopupMenuItem(value: 'Profile', child: Text('Profile')),
          //       PopupMenuItem(value: 'Settings', child: Text('Settings')),
          //       PopupMenuItem(value: 'Logout', child: Text('Logout')),
          //     ];
          //   },
          // ),
          if (_selectedIndex == 4) // Index for Profile Page
            IconButton(
              icon: Icon(
                FontAwesomeIcons.gear,
                color: Colors.white,
                // size: 28,
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
      body: PopScope(
          canPop: canPopNow,
          onPopInvokedWithResult: onPopInvoked,
          child: _pages[_selectedIndex]
      ), // Display selected page
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 2,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.house),
                activeIcon: Icon(FontAwesomeIcons.house, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.robot),
                activeIcon: Icon(FontAwesomeIcons.robot, size: 24),
                label: 'AI Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.magnifyingGlass),
                activeIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 24),
                label: 'Find',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.scroll),
                activeIcon: Icon(FontAwesomeIcons.scroll, size: 24),
                label: 'My Course',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.solidUser),
                activeIcon: Icon(FontAwesomeIcons.solidUser, size: 24),
                label: 'Profile',
              ),
            ],
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: false,
          ),
        ),
    );
  }

  void onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;

    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: requiredSeconds)) {
      currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back twice to exit')),
      );

      Future.delayed(
        Duration(seconds: requiredSeconds),
            () {
          setState(() {
            canPopNow = false;
          });
        },
      );

      setState(() {
        canPopNow = true;
      });
    }
  }
}
