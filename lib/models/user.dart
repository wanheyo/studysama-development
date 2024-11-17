class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? emailVerifiedAt;
  final String? phoneNum;
  final String? createdAt;
  final String? updatedAt;
  final String? bio;
  final int totalFollower;
  final String averageRating;
  final String? socialLink;
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
    required this.verificationStatus,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      emailVerifiedAt: json['email_verified_at'],
      phoneNum: json['phone_num'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      bio: json['bio'],
      totalFollower: json['total_follower'],
      averageRating: json['average_rating'],
      socialLink: json['social_link'],
      verificationStatus: json['verification_status'],
      status: json['status'],
    );
  }
}
