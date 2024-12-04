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
        title: Text(
          'StudySama',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          )
        ,),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          //untuk icons setting
          if (_selectedIndex == 4)  // bila user tekan index ke4 so akan ada icon ni
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
        //backgroundColor: AppColors.background,
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
          fontFamily: 'Montserrat', // Set the font to Montserrat
          fontWeight: FontWeight.bold, // Optional: Make the label bold
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat', // Set the font to Montserrat
          fontWeight: FontWeight.normal, // Optional: Normal weight for unselected labels
        ),
        type: BottomNavigationBarType.fixed, // Keeps label visible on tap
        showUnselectedLabels: false, // Turn off labels for unselected items
      ),
    );
  }
}

