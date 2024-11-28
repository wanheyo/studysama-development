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
                flex: 3,
                child: Container(
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        Column(
                          children: [
                            // Username
                            Text(
                              '@ayunies',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis, // kalau nama panjang
                            ),

                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 30, // Size of the profile image
                              backgroundImage: AssetImage('assets/profile_image.png'),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 23),
                            Text(
                              'BIO: ',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis, // kalau nama panjang
                            ),
                          ],
                        ),
                        //Spacer(),
                        // Follower and Post
                        Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Post',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Text(
                                      '10',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Text(
                                      '120',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            //Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 110, // size button
                                  height: 30,
                                  child: ElevatedButton(
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
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 110, // size button
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Share profile action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    child: Text(
                                      'Share Profile ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCard('Art 1', ''),
                        _buildCard('Art 2', ''),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function for cards
  Widget _buildCard(String title, String imagePath) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
           /* child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),*/
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}