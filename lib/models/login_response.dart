class LoginResponse {
  final String token;
  final Map<String, dynamic> user;
  final String message;

  LoginResponse({
    required this.token,
    required this.user,
    required this.message,
  });
}