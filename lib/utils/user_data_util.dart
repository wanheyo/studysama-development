import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserDataUtil {
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      print("Masuk: " + User.fromJson(json.decode(userString)).toString());
      return User.fromJson(json.decode(userString));
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveUserData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(userData));
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}