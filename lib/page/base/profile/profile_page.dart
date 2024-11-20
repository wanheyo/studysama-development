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
                        ),
                    ),

                    Expanded(
                      flex: 5,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),

                    Align(
                      alignment:Alignment.centerLeft,
                      child:Text(
                        "My Profile",
                        textAlign:TextAlign.left,
                          style:headingTextStyle,
                      )
                    )
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
}*/