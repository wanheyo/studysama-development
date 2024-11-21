
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user.dart';
import '../../../utils/user_data_util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        Map<String, dynamic> userMap = jsonDecode(userString);
        user = User.fromJson(userMap);
      }
      setState(() {
        username = user!.username;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading username: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          if (isLoading)
            CircularProgressIndicator()
          else
            Column(
              children: [
                Text(
                  'Welcome to StudySama! Hi',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  username != null
                      ? 'Hello, $username!'
                      : 'User not found',
                  style: TextStyle(
                    fontSize: 18,
                    color: username != null ? Colors.blue : Colors.red,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

