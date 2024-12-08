import 'package:studysama/models/user.dart';

class UserCourse {
  final int id;
  final int userId;
  final int courseId;
  final int roleId;
  final double? rating;
  final String? commentReview;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  User? user;
  // ResourceFile? resourceFile; // Optional associated file


  UserCourse({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.roleId,
    this.rating,
    this.commentReview,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.user
  });

  // Factory method to create a Lesson object from a JSON map
  factory UserCourse.fromJson(Map<String, dynamic> json) {
    return UserCourse(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      courseId: json['course_id'] as int,
      roleId: json['role_id'] as int,
      rating: json['rating'],
      commentReview: json['comment_review'],
      status: json['status'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Method to convert a Lesson object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'role_id': roleId,
      'rating': rating,
      'comment_review': commentReview,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
