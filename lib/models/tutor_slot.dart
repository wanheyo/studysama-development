// models/tutor_slot.dart

import 'package:flutter/foundation.dart';

class TutorSlot {
  final int id;
  final int courseId;
  final String name;
  final String? desc;
  final String type;
  final DateTime date; // DATE field
  final DateTime startTime; // TIME field
  final DateTime endTime; // TIME field
  final String location;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TutorSlot({
    required this.id,
    required this.courseId,
    required this.name,
    this.desc,
    required this.type,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a TutorSlot object from a JSON map
  factory TutorSlot.fromJson(Map<String, dynamic> json) {
    return TutorSlot(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String?,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String), // DATE field
      startTime: DateTime.parse(json['start_time'] as String), // TIME field
      endTime: DateTime.parse(json['end_time'] as String), // TIME field
      location: json['location'] as String,
      status: json['status'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Method to convert a TutorSlot object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'name': name,
      'desc': desc,
      'type': type,
      'date': date.toIso8601String(), // DATE field
      'start_time': startTime.toIso8601String(), // TIME field
      'end_time': endTime.toIso8601String(), // TIME field
      'location': location,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}