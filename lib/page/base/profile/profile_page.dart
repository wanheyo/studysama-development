import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/colors.dart';

class ProfilePage extends StatelessWidget {
  get headingTextStyle9 => null;
  get headingTextStyle => null;

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences

    // Navigate back to the login screen (replace this with your LoginPage route)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  color: AppColors.primary,
                  child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image and Username in a Column on the left
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 70, // Size of the profile image
                              backgroundImage: AssetImage('assets/profile_image.png'), // Replace with your image path
                              backgroundColor: Colors.white, // Optional: add a background color if the image has transparency
                            ),
                            const SizedBox(height: 8), // Space between image and username
                            Text(
                              '@ayunies', // Replace with the actual username
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis, // To handle long usernames
                            ),
                          ],
                        ),

                        // Spacer to center the followers and button
                        Spacer(),

                        // Followers Count and Edit Profile button in the center
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Followers label and count
                            Text(
                              'Followers',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              '120', // Replace with actual follower count
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 8), // Spacing between count and button
                            // Edit Profile button below followers count
                            ElevatedButton(
                              onPressed: () {
                                // Add the edit profile action here
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColors.primary, backgroundColor: Colors.white, // Text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // Rounded corners
                                ),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Spacer to maintain center alignment
                        Spacer(),

                        // Badge Frame on the right side
                        Container(
                          width: 50, // Width of the badge frame
                          height: 50, // Height of the badge frame
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white, // Border color for badge frame
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                          child: Center(
                            child: Text(
                              'badge', // Placeholder for badge (can replace with an icon or image)
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
  Align(
                      alignment:Alignment.centerLeft,
                      child:Text(
                        "My Profile",
                        textAlign:TextAlign.left,
                          style:headingTextStyle,
                      )
                    )
}*/