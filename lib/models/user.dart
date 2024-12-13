class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final DateTime? emailVerifiedAt;
  final String? phoneNum;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bio;
  final int totalFollower;
  final double averageRating;
  final String? socialLink;
  final String? image;
  final int verificationStatus;
  final int status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.emailVerifiedAt,
    this.phoneNum,
    this.createdAt,
    this.updatedAt,
    this.bio,
    required this.totalFollower,
    required this.averageRating,
    this.socialLink,
    this.image,
    required this.verificationStatus,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      phoneNum: json['phone_num'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      bio: json['bio'],
      totalFollower: json['total_follower'],
      averageRating: json['average_rating'] is String
          ? double.parse(json['average_rating'] as String)
          : (json['average_rating'] as num).toDouble(),
      socialLink: json['social_link'],
      image: json['image'],
      verificationStatus: json['verification_status'],
      status: json['status'],
    );
  }
}
