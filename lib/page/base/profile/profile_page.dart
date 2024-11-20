import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/colors.dart';


class ProfilePage extends StatelessWidget {


  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences

    // Navigate back to the login screen (replace this with your LoginPage route)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors
              .purple, // Change this to your preferred background color
          // Uncomment and replace the image path if you want a background image
          // image: DecorationImage(
          //   image: AssetImage('assets/background.png'),
          //   fit: BoxFit.cover,
          // ),
        ),
        child: Center(
          child: Text(
            'My Profile',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}




/*child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text(
           'here!',
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
}*/