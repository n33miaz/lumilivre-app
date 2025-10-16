import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

class LoginResponse {
  final int id;
  final String email;
  final String role;
  final String? matriculaAluno;
  final String token;

  LoginResponse({
    required this.id,
    required this.email,
    required this.role,
    this.matriculaAluno,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    id: json["id"],
    email: json["email"],
    role: json["role"],
    matriculaAluno: json["matriculaAluno"],
    token: json["token"],
  );
}
