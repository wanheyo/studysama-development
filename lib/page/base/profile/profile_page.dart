import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../../utils/colors.dart';
import 'edit_profile.dart';

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
                        // Profile Image
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 70, // Size of the profile image
                              backgroundImage: AssetImage('assets/profile_image.png'),
                              backgroundColor: Colors.white, //
                            ),
                            const SizedBox(height: 10),
                            //username
                            Text(
                              '@ayunies',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis, // kalau nama panjang
                            ),
                          ],
                        ),


                        Spacer(),

                        // Follower and post
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Row for Post and Followers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Column for Posts
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Post',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Text(
                                      '10',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 40),

                                // Column for Followers
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Text(
                                      '120',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Row for Edit Profile and Share Profile Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add the share profile action here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Share Profile',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Spacer(),// space

                        // Badge Frame
                        Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'badge',
                              style: TextStyle(
                                fontSize: 17,
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
