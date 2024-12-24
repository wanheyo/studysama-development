import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/page/auth/login_page.dart'; // Import your LoginPage
import 'package:studysama/utils/colors.dart';

import '../../../services/api_service.dart'; // Import your AppColors

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ApiService apiService = ApiService();
  String token = "";

  @override
  void initState() {
    super.initState();
    loadUser (); // Call loadUser  when the page is opened
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadUser () async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        setState(() {
          token = tokenString; // Update the state with the loaded token
        });
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // Function to handle logout
  Future<void> _showLogOutConfirmation(BuildContext context) async {
    // Show the confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            // No Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('No'),
            ),
            // Yes Button
            TextButton(
              onPressed: () async {
                // Clear shared preferences (you can also clear specific data if needed)
                _logout();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear all data from SharedPreferences

                // Navigate to LoginPage and clear the navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                      (route) => false,  // This removes all previous routes (back navigation disabled)
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      // Call the API and get the updated course data
      await apiService.logout(token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User logout successfully!'),
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course update failed: $errorMsg')),
      );
      print(errorMsg);
    } finally {
      // setState(() {
      //   context.loaderOverlay.hide();
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(FontAwesomeIcons.arrowRightFromBracket),
              title: Text(
                "Log Out",
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onTap: () {
                _showLogOutConfirmation(context);  // Trigger logout confirmation on tap
              },
            ),
          ],
        ),
      ),
    );
  }
}