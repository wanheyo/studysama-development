import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/utils/colors.dart';
import '../base/base_page.dart';
import 'login_page.dart'; // Import the login page

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  void _checkStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve token and auto-login if valid
    final storedToken = prefs.getString('token');
    // final storedUser = prefs.getString('user');

    if (storedToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BasePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkStoredCredentials(); // Check for stored credentials
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date and time
    String formattedDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(  // Center all the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Replacing Image.asset with Image.network
              Image.asset(
                'assets/SS_Header_Transparent_16-9.png', // Path relative to the assets folder
                fit: BoxFit.cover,
                height: 100,
                width: 300,
              ),
              SizedBox(height: 50,),
              // Padding(
              //   padding: const EdgeInsets.only(top: 20),
              //   child: Column(
              //     children: [
              //       Text(
              //         '$formattedDate',
              //         style: TextStyle(
              //           fontSize: 18,
              //           color: Colors.white70,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //       SizedBox(height: 5),
              //       Text(
              //         '$formattedTime',
              //         style: TextStyle(
              //           fontSize: 18,
              //           color: Colors.white70,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to your existing LoginPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Slightly rounded corners
                    ),
                    padding: EdgeInsets.symmetric(vertical: 22, horizontal: 50), // Increased padding
                    elevation: 5, // Button shadow
                    minimumSize: Size(200, 60), // Minimum width and height
                  ),
                  child: Text(
                    'LET’S START',
                    style: TextStyle(
                      fontSize: 16, // Larger font size
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Let’s learn something new today!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic, // Italic text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
