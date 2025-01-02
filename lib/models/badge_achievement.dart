// File: models/badge_achievement.dart

class BadgeAchievement {
  final int id;
  final String name;
  final String desc;
  final String? rarity;
  final int totalUser;
  final int status;
  final String? logoImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Constructor
  BadgeAchievement({
    required this.id,
    required this.name,
    required this.desc,
    this.rarity,
    this.totalUser = 0,
    required this.status,
    this.logoImage,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create an instance from a JSON map
  factory BadgeAchievement.fromJson(Map<String, dynamic> json) {
    return BadgeAchievement(
      id: json['id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String,
      rarity: json['rarity'] as String?,
      totalUser: json['total_user'] as int? ?? 0,
      status: json['status'] as int,
      logoImage: json['logo_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'rarity': rarity,
      'total_user': totalUser,
      'status': status,
      'logo_image': logoImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
