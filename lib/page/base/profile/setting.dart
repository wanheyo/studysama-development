import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/page/auth/login_page.dart'; // Import your LoginPage
import 'package:studysama/utils/colors.dart'; // Import your AppColors

class SettingsPage extends StatelessWidget {
  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('My Profile'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _logout(context);  // Trigger logout confirmation on tap
              },
            ),
          ],
        ),
      ),
    );
  }
}
