import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import '../models/user.dart';

class ApiService {
  //production
  // final String baseUrl = 'https://{domain}/api/studysama';

  //development
  final String baseUrl = 'https://9452-2001-e68-8222-e00-883b-f73d-2694-6333.ngrok-free.app/api/studysama';

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/index'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if required
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<void> user_store(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/store'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        // Handle success
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body.trim());
          print('Success: $responseData');
        }
        return;
      } else {
        // Handle validation errors
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body.trim());

          // Check if the response contains 'errors'
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            String errorMessage = '';

            // Check for specific error messages for username and email
            if (errors.containsKey('username')) {
              errorMessage += '${errors['username'][0]}\n';
            }
            if (errors.containsKey('email')) {
              errorMessage += '${errors['email'][0]}\n';
            }
            if (errors.containsKey('password')) {
              errorMessage += '${errors['password'][0]}\n';
              // errorMessage = errors['password'][0];  // Get the first error message for password
            }

            // Throw the combined error message
            throw Exception(errorMessage.trim());
          } else {
            // Fallback error if no validation errors are present
            throw Exception(responseData['message'] ?? 'Failed to register user');
          }
        }
      }
    } catch (e) {
      // Rethrow the exception for the caller to handle
      // throw Exception('Error registering user: $e');
      throw Exception(e);
    }
  }

  Future<LoginResponse> login(String usernameOrEmail, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'login': usernameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return LoginResponse(
          token: responseData['token'],
          user: responseData['user'],
          message: responseData['message'],
        );
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to login');
        } else {
          throw Exception('Failed to login: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  Future<void> logout(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode(<String, String>{
        //   'login': usernameOrEmail,
        //   'password': password,
        // }),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body.trim());
          print('Success Logout: $responseData');
        }
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to logout');
        } else {
          throw Exception('Failed to logout: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error logging out: $e');
    }
  }

  Future<void> course_store(String token, String name, String desc) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'desc': desc,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        // Handle success
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body.trim());
          print('Success: $responseData');
        }
        return;
      } else {
        // Handle validation errors
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body.trim());

          // Check if the response contains 'errors'
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            String errorMessage = '';

            // Throw the combined error message
            throw Exception(errorMessage.trim());
          } else {
            // Fallback error if no validation errors are present
            throw Exception(responseData['message'] ?? 'Failed to create course');
          }
        }
      }
    } catch (e) {
      // Rethrow the exception for the caller to handle
      // throw Exception('Error registering user: $e');
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> index_user_course(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/index_user_course'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch courses');
        } else {
          throw Exception('Failed to fetch courses: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching user courses: $e');
    }
  }

  Future<Map<String, dynamic>> index_lesson_course(String token, int course_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lesson/index_lesson_course'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'course_id': course_id}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch lesson');
        } else {
          throw Exception('Failed to fetch lessons: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }
}