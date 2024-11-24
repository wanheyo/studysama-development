import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import '../models/user.dart';

class ApiService {
  //production
  // final String baseUrl = 'https://{domain}/api/studysama';

  //development
  final String baseUrl = 'https://8d0d-2001-e68-823e-a00-846f-4f53-251-6354.ngrok-free.app/api/studysama';

  // SECTION START: USER

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/index'),
        headers: {
          'Content-Type': 'application/json',
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

  // SECTION END: LESSON


  // SECTION START: COURSE

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

  Future<Map<String, dynamic>> course_update(
      String token, int course_id, String name, String desc, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'course_id': course_id,
          'name': name,
          'desc': desc,
          'status': status,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse and return the updated course data
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = json.decode(response.body.trim());
          print('Success: $responseData');

          // Ensure 'message' and 'course' exist in the response
          if (responseData.containsKey('message') &&
              responseData.containsKey('course')) {
            return responseData;
          } else {
            throw Exception('Invalid response structure: ${response.body}');
          }
        } else {
          throw Exception('Empty response body on success');
        }
      } else {
        // Handle error responses
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> errorData = json.decode(response.body.trim());

          // If errors are present in the response, process them
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            String errorMessage = errors.values.join(', ');
            throw Exception(errorMessage.trim());
          } else {
            // Fallback error handling
            throw Exception(errorData['message'] ?? 'Failed to update course');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error updating course: $e');
    }
  }

  Future<Map<String, dynamic>> index_all_course(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/course/index_all'),
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
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<Map<String, dynamic>> index_course(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/index_course'),
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
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<Map<String, dynamic>> index_user_course(String token, int course_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/index_user_course'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'course_id': course_id,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch user courses');
        } else {
          throw Exception('Failed to fetch user courses: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching user courses: $e');
    }
  }

  Future<Map<String, dynamic>> update_user_course(String token, int course_id, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/update_user_course'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'course_id': course_id,
          'status': status,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse and return the updated course data
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = json.decode(response.body.trim());
          print('Success: $responseData');

          // Ensure 'message' exist in the response
          if (responseData.containsKey('message')) {
            return responseData;
          } else {
            throw Exception('Invalid response structure: ${response.body}');
          }
        } else {
          throw Exception('Empty response body on success');
        }
      } else {
        // Handle error responses
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> errorData = json.decode(response.body.trim());

          // If errors are present in the response, process them
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            String errorMessage = errors.values.join(', ');
            throw Exception(errorMessage.trim());
          } else {
            // Fallback error handling
            throw Exception(errorData['message'] ?? 'Failed to update course');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error updating course: $e');
    }
  }

  // SECTION END: COURSE


  // SECTION START: LESSON

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

  Future<void> lesson_store(String token, String name, int course_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lesson/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'learn_outcome': 'Student will get ...',
          'desc': "Lesson for " + name,
          'course_id': course_id,
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
            throw Exception(responseData['message'] ?? 'Failed to create lesson');
          }
        }
      }
    } catch (e) {
      // Rethrow the exception for the caller to handle
      // throw Exception('Error registering user: $e');
      throw Exception(e);
    }
  }

  // SECTION END: LESSON


}