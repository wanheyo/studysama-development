import 'dart:convert';

class ResourceFile {
  final int id;
  final String name;
  final String type;
  final int totalDownload;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResourceFile({
    required this.id,
    required this.name,
    required this.type,
    this.totalDownload = 0,
    this.status = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Course instance from JSON
  factory ResourceFile.fromJson(Map<String, dynamic> json) {
    return ResourceFile(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      totalDownload: json['total_download'] as int? ?? 0,
      status: json['status'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Method to convert a Course instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'total_download': totalDownload,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // To pretty-print JSON (optional)
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
