import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import 'package:http_parser/http_parser.dart'; // For MIME types
import 'package:path/path.dart' as p;
import 'package:html/parser.dart' as html;


class ApiService {
  //production
  // final String domainUrl = 'https://{domain}';

  //development
  final String domainUrl = 'https://ac15-2001-e68-821b-8300-3d96-c442-99b7-aa45.ngrok-free.app';
  late final String baseUrl;

  final openAIUrl = Uri.parse('https://api.openai.com/v1/chat/completions');
  final String openAIKey = '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';

  ApiService() {
    baseUrl = domainUrl + '/api/studysama';
  }

  // SECTION START: USER

  Future<Map<String, dynamic>> index_all_user(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/index_all'),
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
          throw Exception(responseData['message'] ?? 'Failed to fetch users');
        } else {
          throw Exception('Failed to fetch users: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<Map<String, dynamic>> index_user(String token, int? user_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/index_user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': user_id
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch user');
        } else {
          throw Exception('Failed to fetch user: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
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

  Future<Map<String, dynamic>> user_update(String token, String? username, String? name, String? bio, String? email, String? phoneNum, File? picked_image, int? status) async {
    if(picked_image != null) {
      print(picked_image.path.toString());
    }

    try {
      // Set up the request
      final uri = Uri.parse('$baseUrl/users/update');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields only if they are not null
      if (username != null) request.fields['username'] = username;
      if (name != null) request.fields['name'] = name;
      if (bio != null) request.fields['bio'] = bio;
      if (email != null) request.fields['email'] = email;
      if (phoneNum != null) request.fields['phone_num'] = phoneNum;
      if (status != null) request.fields['status'] = status.toString();

      // Attach the file if it exists
      if (picked_image != null) {
        final mimeType = lookupMimeType(picked_image.path) ?? 'application/octet-stream';

        request.files.add(await http.MultipartFile.fromPath(
          'image', // This key should match what the server expects
          picked_image.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse and return the updated course data
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> responseData = json.decode(response.body.trim());
          print('Success: $responseData');

          // Ensure 'message' and 'course' exist in the response
          if (responseData.containsKey('message') &&
              responseData.containsKey('user')) {
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
            final errors = errorData['errors'] as List<dynamic>;
            String errorMessage = errors.join(', ');
            throw Exception(errorMessage.trim());
          } else {
            // Fallback error handling
            throw Exception(errorData['message'] ?? 'Failed to update user');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception(e.toString());
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

  Future<Map<String, dynamic>> index_follow(String token, int? user_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/index_follow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': user_id
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch user follow');
        } else {
          throw Exception('Failed to fetch user follow: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching user follow: $e');
    }
  }

  Future<Map<String, dynamic>> update_follow(String token, int? user_followed_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/update_follow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_followed_id': user_followed_id
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch update follow');
        } else {
          throw Exception('Failed to fetch update follow: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching update follow: $e');
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

  Future<Map<String, dynamic>> course_update(String token, int course_id, String name, String desc, int status) async {
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

  Future<Map<String, dynamic>> index_course(String token, int? user_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/index_course'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': user_id
        }),
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

  Future<Map<String, dynamic>> index_course_courseid(String token, int course_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/index_course_courseid'),
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

  Future<Map<String, dynamic>> index_review(String token, int course_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/index_review'),
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
          throw Exception(responseData['message'] ?? 'Failed to fetch user courses (review)');
        } else {
          throw Exception('Failed to fetch user courses (review): ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching user courses (review): $e');
    }
  }

  Future<Map<String, dynamic>> update_review(String token, int user_course_id, int rating, String comment_review, int is_delete) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/update_review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_course_id': user_course_id,
          'rating': rating,
          'comment_review': comment_review,
          'is_delete': is_delete,
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
            throw Exception(errorData['message'] ?? 'Failed to update user courses (review)');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error updating user courses (review): $e');
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

  Future<void> lesson_store(String token, String name, String learn_outcome, String description, int course_id) async {
    if(learn_outcome == "" || learn_outcome.isEmpty)
      learn_outcome = "Student will get ...";

    if(description == "" || description.isEmpty)
      description = "Lesson for " + name;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lesson/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'learn_outcome': learn_outcome,
          'desc': description,
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

  Future<Map<String, dynamic>> lesson_update(String token, int lesson_id, String name, String desc, String learn_outcome, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lesson/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lesson_id': lesson_id,
          'name': name,
          'desc': desc,
          'learn_outcome': learn_outcome,
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
              responseData.containsKey('lesson')) {
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
            throw Exception(errorData['message'] ?? 'Failed to update lesson');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error updating lesson: $e');
    }
  }

  // SECTION END: LESSON


  // SECTION START: RESOURCE

  Future<Map<String, dynamic>> index_resource_lesson(String token, int lesson_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resource/index_resource_lesson'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'lesson_id': lesson_id}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch resource');
        } else {
          throw Exception('Failed to fetch resource: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  Future<void> resource_store(String token, String name, String desc, int category, String link, int lesson_id, String file_name, String file_type, File? picked_file) async {

    if(picked_file != null) {
      print(picked_file.path.toString());
      file_name = p.basename(picked_file.path);
      file_type = p.extension(picked_file.path);
    }

    try {
      // Set up the request
      final uri = Uri.parse('$baseUrl/resource/store');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['category'] = category.toString();
      request.fields['link'] = link;
      request.fields['lesson_id'] = lesson_id.toString();
      request.fields['file_name'] = file_name;
      request.fields['file_type'] = file_type;

      // Attach the file if it exists
      if (picked_file != null) {
        final mimeType = lookupMimeType(picked_file.path) ?? 'application/octet-stream';

        request.files.add(await http.MultipartFile.fromPath(
          'file', // This key should match what the server expects
          picked_file.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      // Send the request
      final response = await request.send();

      // Parse the response
      if (response.statusCode == 201) {
        // Successful response
        final responseBody = await response.stream.bytesToString();
        print('Error response body: $responseBody'); // Log the entire response body
        if (responseBody.isNotEmpty) {
          final responseData = json.decode(responseBody.trim());
          print('Success: $responseData');
        }
      } else {
        // Handle errors
        final responseBody = await response.stream.bytesToString();
        if (responseBody.isNotEmpty) {
          final responseData = json.decode(responseBody.trim());

          // Check for validation errors
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            String errorMessage = '';

            // Process specific field errors
            if (errors.containsKey('name')) {
              errorMessage += '${errors['name'][0]}\n';
            }
            if (errors.containsKey('desc')) {
              errorMessage += '${errors['desc'][0]}\n';
            }
            if (errors.containsKey('file')) {
              errorMessage += '${errors['file'][0]}\n';
            }

            // Throw the combined error message
            throw Exception(errorMessage.trim());
          } else {
            // General error message
            throw Exception(responseData['message'] ?? 'Failed to create resource');
          }
        } else {
          throw Exception('Failed to create resource: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Log and rethrow the exception
      print('Error: $e');
      throw Exception('Error creating resource: $e');
    }
  }

  Future<void> resource_update(String token, int isUpdateFile, String name, String desc, int category, String link, int resource_id, String file_name, String file_type, int? file_id, File? picked_file, int status) async {

    if(picked_file != null) {
      print(picked_file.path.toString());
      file_name = p.basename(picked_file.path);
      file_type = p.extension(picked_file.path);
    }

    try {
      // Set up the request
      final uri = Uri.parse('$baseUrl/resource/update');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      request.fields['isUpdateFile'] = isUpdateFile.toString();
      request.fields['resource_id'] = resource_id.toString();
      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['category'] = category.toString();

      if(isUpdateFile != 1)
        request.fields['link'] = link;

      request.fields['status'] = status.toString();

      if(file_id != null)
        request.fields['file_id'] = file_id.toString();

      request.fields['file_name'] = file_name;

      // Attach the file if it exists
      if (picked_file != null) {
        final mimeType = lookupMimeType(picked_file.path) ?? 'application/octet-stream';

        request.files.add(await http.MultipartFile.fromPath(
          'file', // This key should match what the server expects
          picked_file.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      // Send the request
      final response = await request.send();

      // Parse the response
      if (response.statusCode == 201) {
        // Successful response
        final responseBody = await response.stream.bytesToString();
        print('Error response body: $responseBody'); // Log the entire response body
        if (responseBody.isNotEmpty) {
          final responseData = json.decode(responseBody.trim());
          print('Success: $responseData');
        }
      } else {
        // Handle errors
        final responseBody = await response.stream.bytesToString();
        if (responseBody.isNotEmpty) {
          final responseData = json.decode(responseBody.trim());

          // Check for validation errors
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            String errorMessage = '';

            // Process specific field errors
            if (errors.containsKey('name')) {
              errorMessage += '${errors['name'][0]}\n';
            }
            if (errors.containsKey('desc')) {
              errorMessage += '${errors['desc'][0]}\n';
            }
            if (errors.containsKey('file')) {
              errorMessage += '${errors['file'][0]}\n';
            }

            // Throw the combined error message
            throw Exception(errorMessage.trim());
          } else {
            // General error message
            throw Exception(responseData['message'] ?? 'Failed to update resource');
          }
        } else {
          throw Exception('Failed to update resource: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Log and rethrow the exception
      print('Error: $e');
      throw Exception('Error updating resource: $e');
    }
  }

// SECTION END: RESOURCE

// SECTION START: COMMENT

  Future<Map<String, dynamic>> index_comment_resource(String token, int resource_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comment/index_comment_resource'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'resource_id': resource_id}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to fetch comment');
        } else {
          throw Exception('Failed to fetch comment: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching comment: $e');
    }
  }

  Future<void> comment_store(String token, int user_course_id, int resource_id, String comment_text) async {

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comment/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_course_id': user_course_id,
          'resource_id': resource_id,
          'comment_text': comment_text,
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
            throw Exception(responseData['message'] ?? 'Failed to create comment');
          }
        }
      }
    } catch (e) {
      // Rethrow the exception for the caller to handle
      throw Exception('Error creating comment: $e');
    }
  }

  Future<Map<String, dynamic>> comment_update(String token, int comment_id, int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comment/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'comment_id': comment_id,
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
              responseData.containsKey('comment')) {
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
            throw Exception(errorData['message'] ?? 'Failed to update comment');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error updating comment: $e');
    }
  }

// SECTION END: COMMENT

// SECTION START: TUTOR SLOT

  Future<Map<String, dynamic>> index_tutorslot_course(String token, int course_id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tutorslot/index_tutorslot_course'),
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
          throw Exception(responseData['message'] ?? 'Failed to fetch tutor slots');
        } else {
          throw Exception('Failed to fetch tutor slots: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching tutor slots: $e');
    }
  }

  Future<void> tutorslot_store(String token, String name, String learnOutcome, String desc, int courseId, String type, DateTime date, DateTime startTime, DateTime endTime, String location,) async {

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tutorslot/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'course_id': courseId,
          'name': name,
          'desc': desc,
          'type': type,
          'date': date.toIso8601String().split('T')[0], // Format date to ISO 8601
          'start_time': startTime.toIso8601String().split('T')[1].substring(0, 5), // Format start time to ISO 8601
          'end_time': endTime.toIso8601String().split('T')[1].substring(0, 5), // Format end time to ISO 8601
          'location': location,
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

            // Combine error messages
            if (errors is Map) {
              errors.forEach((key, value) {
                errorMessage += '$key: $value\n';
              });
            } else if (errors is List) {
              errorMessage = errors.join('\n');
            }

            // Throw the combined error message
            throw Exception(errorMessage.trim());
          } else {
            // Fallback error if no validation errors are present
            throw Exception(responseData['message'] ?? 'Failed to create tutor slot');
          }
        }
      }
    } catch (e) {
      // Rethrow the exception for the caller to handle
      throw Exception('Error creating tutor slot: $e');
    }
  }

  Future<Map<String, dynamic>> tutorslot_update(String token, int tutorSlotId, String name, String desc, String type, DateTime date, DateTime startTime, DateTime endTime, String location, int status)  async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tutorslot/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'tutor_slot_id': tutorSlotId,
          'name': name,
          'desc': desc,
          'type': type,
          'date': date.toIso8601String().split('T')[0], // Format date to ISO 8601
          'start_time': startTime.toIso8601String().split('T')[1].substring(0, 5), // Format start time to ISO 8601
          'end_time': endTime.toIso8601String().split('T')[1].substring(0, 5), // Format end time to ISO 8601
          'location': location,
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

          // Ensure 'message' and 'tutor_slot' exist in the response
          if (responseData.containsKey('message') &&
              responseData.containsKey('tutor_slot')) {
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
            throw Exception(errorData['message'] ?? 'Failed to update tutor slot');
          }
        }
        throw Exception('Unexpected response format or empty response body');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error updating tutor slot: $e');
    }
  }

// SECTION END: TUTOR SLOT

// SECTION START: OPEN AI

  Future<Map<String, dynamic>> generateQuizFromUrl(String url) async {
    String textContent = url;

    try {
      final openAiResponse = await http.post(
        openAIUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an assistant that generates multiple-choice quizzes based on input text.',
            },
            {
              'role': 'user',
              'content': '''
            Generate 5 multiple-choice questions based on the following url:
            $textContent
            Each question should have 4 options with one correct answer. Provide the response in this structure:
            Question: [Question Text]
            Options: [Option1; Option2; Option3; Option4]
            Answer: [Correct answer index of option]
            Response should be like this, the answer should be an index of the option, ignore space in response except in context of title, question, options and answer
            
          ''',
            },
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      // Log the raw response body for debugging
      print('OpenAI Raw Response: ${openAiResponse.body}');

      if (openAiResponse.statusCode == 200) {
        final data = jsonDecode(openAiResponse.body);

        // Verify the presence of 'choices' and 'message' keys
        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final message = data['choices'][0]['message'];
          if (message != null && message.containsKey('content')) {
            final rawText = message['content'];
            print('Raw Text from OpenAI: $rawText');

            // Process the raw text into structured format
            final questions = _processQuizText(rawText);

            final response = {
              "title": "Quiz from $url",
              "data": questions,
            };

            // Debugging output
            print('Quiz Title: ${response["title"]}');
            print('Quiz Data: ${response["data"]}');

            return response;
          } else {
            throw Exception('Invalid OpenAI response: Missing "content" in "message".');
          }
        } else {
          throw Exception('Invalid OpenAI response: Missing "choices" or "message".');
        }
      } else {
        throw Exception('Failed to generate quiz: ${openAiResponse.body}');
      }
    } catch (e) {
      // Log the error for debugging
      print('Error in generateQuizFromUrl: $e');
      rethrow;
    }
  }

  // Helper function to parse raw text into structured format
  List<Map<String, dynamic>> _processQuizText(String rawText) {
    final lines = rawText.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final questions = <Map<String, dynamic>>[];

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith("Question: ")) {
        final questionText = lines[i].replaceFirst("Question: ", "").trim();
        final options = lines[i + 1]
            .replaceFirst("Options: ", "")
            .replaceAll("[", "")
            .replaceAll("]", "")
            .split(';')
            .map((e) => e.trim())
            .toList();
        final answerIndex = int.tryParse(lines[i + 2].replaceFirst("Answer: ", "").trim());

        if (answerIndex != null && answerIndex >= 0 && answerIndex < options.length) {
          questions.add({
            "question": questionText,
            "options": options,
            "answer": answerIndex,
          });
        }
      }
    }

    return questions;
  }

// SECTION END: OPEN AI
}