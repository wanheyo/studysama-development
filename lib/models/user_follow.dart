import 'package:studysama/models/user.dart';

class UserFollow {
  final int id;
  final int userFollowerId;
  final int userFollowedId;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  User? userFollower;
  User? userFollowed;
  // ResourceFile? resourceFile; // Optional associated file

  UserFollow({
    required this.id,
    required this.userFollowerId,
    required this.userFollowedId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.userFollower,
    this.userFollowed
  });

  // Factory method to create a Lesson object from a JSON map
  factory UserFollow.fromJson(Map<String, dynamic> json) {
    return UserFollow(
      id: json['id'] as int,
      userFollowerId: json['user_follower_id'] as int,
      userFollowedId: json['user_followed_id'] as int,
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
      'user_follower_id': userFollowerId,
      'user_followed_id': userFollowedId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
