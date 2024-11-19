// models/course.dart

import 'package:flutter/foundation.dart';

class Lesson {
  final int id;
  final int courseId;
  final String name;
  final String? learnOutcome;
  final String? description;
  final int totalVisit;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.name,
    this.learnOutcome,
    this.description,
    required this.totalVisit,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a Course object from a JSON map
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      name: json['name'] as String,
      learnOutcome: json['learn_outcome'] as String?,
      description: json['desc'] as String?,
      totalVisit: json['total_visit'] as int,
      status: json['status'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Method to convert a Course object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'name': name,
      'learn_outcome': learnOutcome,
      'desc': description,
      'total_visit': totalVisit,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
