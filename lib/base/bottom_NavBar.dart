import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../page/home_Page.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {

  final appScreens = [
    // const Text("Home"),
    // const Text("List"),
    // const Text("Profile"),
    const HomePage(),
    const Text("List"),
    const Text("Profile"),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test123"),
        centerTitle: true,
      ),
      body: Center(
        child: appScreens[_selectedIndex],
      ),
      bottomNavigationBar: SizedBox(
        height: 70, // Adjust height as needed
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 10), // Add top padding
                child: Icon(FluentSystemIcons.ic_fluent_home_regular),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 10), // Add top padding for active icon
                child: Icon(FluentSystemIcons.ic_fluent_home_filled),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(FluentSystemIcons.ic_fluent_apps_list_regular),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(FluentSystemIcons.ic_fluent_apps_list_filled),
              ),
              label: "List",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(FluentSystemIcons.ic_fluent_person_regular),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(FluentSystemIcons.ic_fluent_person_filled),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
