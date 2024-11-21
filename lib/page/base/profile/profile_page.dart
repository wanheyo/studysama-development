import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';

class ProfilePage extends StatelessWidget {
  final ApiService apiService = ApiService();
  String token = "";

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenString = prefs.getString('token');
    if (tokenString != null) {
      token = tokenString;
    }

    try {
      await apiService.logout(token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully logout',
          ),
        ),
      );
    } catch (e) {
      // setState(() {
      //   errorMessage = e.toString();
      //   print("Response: " + e.toString());
      // });
      final errorMsg = e.toString().replaceFirst('Exception: ', '\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $errorMsg\n')),
      );
      print(errorMsg);
    } finally {
      // setState(() {
      //   //context.loaderOverlay.hide();
      //   isLoading = false;
      // });

      await prefs.clear(); // Clear all data from SharedPreferences

      // Navigate back to the login screen (replace this with your LoginPage route)
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'View your profile details here!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context), // Call logout method
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Log Out',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
