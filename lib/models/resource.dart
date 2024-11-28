import 'package:studysama/models/resource_file.dart';

class Resource {
  final int id;
  final int lessonId;
  final String name;
  final String? description;
  final String? link;
  final int category;
  final int totalVisit;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? fileId;
  ResourceFile? resourceFile; // Optional associated file

  Resource({
    required this.id,
    required this.lessonId,
    required this.name,
    this.description,
    this.link,
    required this.category,
    required this.totalVisit,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.fileId,
    this.resourceFile
  });

  // Factory method to create a Lesson object from a JSON map
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int,
      name: json['name'] as String,
      description: json['desc'] as String?,
      link: json['link'] as String?,
      category: json['category'] as int,
      totalVisit: json['total_visit'] as int,
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
      'lesson_id': lessonId,
      'name': name,
      'desc': description,
      'link': link,
      'category': category,
      'total_visit': totalVisit,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'file_id': fileId,
    };
  }
}
