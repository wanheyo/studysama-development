import 'package:flutter/material.dart';

void main() {
  runApp(startpage());
}

class startpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Section
            Column(
              children: [
                SizedBox(height: 40),
                // Icon
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                // Main Title
                Text(
                  "Let's Start Learning!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                // Subtitle
                Text(
                  "Access courses anywhere and stay ahead!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // "Get Started" Button
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the home page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),

            // Bottom Navigation Bar (Icons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.home, size: 30, color: Colors.black54),
                      SizedBox(height: 5),
                      Text("Home", style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.menu_book, size: 30, color: Colors.black54),
                      SizedBox(height: 5),
                      Text("Courses", style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.person, size: 30, color: Colors.black54),
                      SizedBox(height: 5),
                      Text("Profile", style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "Welcome to Study Sama!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
