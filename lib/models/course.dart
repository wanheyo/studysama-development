import 'dart:convert';

class Course {
  final int id;
  final String name;
  final String? desc;
  final int totalVisit;
  final int totalJoined;
  final double averageRating;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? role_id;

  Course({
    required this.id,
    required this.name,
    this.desc,
    this.totalVisit = 0,
    this.totalJoined = 0,
    this.averageRating = 5.0,
    this.status = 1,
    required this.createdAt,
    required this.updatedAt,
    this.role_id,
  });

  // Factory constructor to create a Course instance from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String?,
      totalVisit: json['total_visit'] as int,
      totalJoined: json['total_joined'] as int,
      averageRating: json['average_rating'] is String
          ? double.parse(json['average_rating'] as String)
          : (json['average_rating'] as num).toDouble(),
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      role_id: json['role_id'] as int?,
    );
  }

  // Method to convert a Course instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'total_visit': totalVisit,
      'total_joined': totalJoined,
      'average_rating': averageRating,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      'role_id': role_id,
    };
  }

  // To pretty-print JSON (optional)
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
