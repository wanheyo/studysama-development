import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'login_page.dart'; // Import the login page


class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current date and time
    String formattedDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color(0xFF8A56AC),
      body: SafeArea(
        child: Center(  // Center all the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Text(
                  'Welcome to\nStudy Sama',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto', // Custom font
                    letterSpacing: 1.2, // Adds space between letters
                  ),
                ),
              ),
              // Replacing Image.asset with Image.network
              Image.asset(
                'assets/logo.png', // Path relative to the assets folder
                fit: BoxFit.cover,
                height: 250,
                width: 300,
              )
              ,
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Text(
                      '$formattedDate',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$formattedTime',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
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
                    backgroundColor: Color(0xFF6B4FA6),
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
                      fontSize: 24, // Larger font size
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
