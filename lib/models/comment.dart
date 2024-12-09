import 'package:studysama/models/resource.dart';
import 'package:studysama/models/resource_file.dart';
import 'package:studysama/models/user_course.dart';

class Comment {
  final int id;
  final int userCourseId;
  final int resourceId;
  final String commentText;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? fileId;
  ResourceFile? resourceFile; // Optional associated file
  UserCourse? userCourse;
  Resource? resource;

  Comment({
    required this.id,
    required this.userCourseId,
    required this.resourceId,
    required this.commentText,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.fileId,
    this.resourceFile,
    this.userCourse,
    this.resource,
  });

  // Factory method to create a Lesson object from a JSON map
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userCourseId: json['user_course_id'] as int,
      resourceId: json['resource_id'] as int,
      commentText: json['comment_text'] as String,
      status: json['status'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      fileId: json['file_id'] as int?,
    );
  }

  // Method to convert a Lesson object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_course_id': userCourseId,
      'resource_id': resourceId,
      'comment_text': commentText,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'file_id': fileId,
    };
  }
}
