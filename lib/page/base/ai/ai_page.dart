
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user.dart';
import '../../../utils/colors.dart';
import '../../../utils/user_data_util.dart';

class AiPage extends StatefulWidget {
  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
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

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences

    // Navigate back to the login screen (replace this with your LoginPage route)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.bots, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    'AI Page',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _logout(context);
                      },
                      icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(fontFamily: 'Montserrat'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}