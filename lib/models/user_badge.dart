// File: models/user_badge.dart

import 'package:studysama/models/badge_achievement.dart';

class UserBadge {
  final int id;
  final int userId;
  final int badgeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int status;
  BadgeAchievement? badgeAchievement;

  // Constructor
  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    this.createdAt,
    this.updatedAt,
    required this.status,
    this.badgeAchievement,
  });

  // Factory method to create an instance from a JSON map
  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      badgeId: json['badge_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      status: json['status'] as int,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
    };
  }
}
