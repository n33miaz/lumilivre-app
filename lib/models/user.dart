import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

class LoginResponse {
  final String id;
  final String email;
  final String role;
  final String? readerRegistrationNumber;
  final String token;
  final bool isInitialPassword;

  LoginResponse({
    required this.id,
    required this.email,
    required this.role,
    this.readerRegistrationNumber,
    required this.token,
    required this.isInitialPassword,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json["id"]?.toString() ?? '',
      email: json["email"],
      role: json["role"],
      readerRegistrationNumber:
          json["readerRegistrationNumber"] ??
          json["registrationNumber"] ??
          json["matriculaAluno"] ??
          json["studentRegistrationNumber"],
      token: json["token"],
      isInitialPassword:
          json["initialPasswordChange"] ?? json["isInitialPassword"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "role": role,
    "readerRegistrationNumber": readerRegistrationNumber,
    "token": token,
    "initialPasswordChange": isInitialPassword,
  };
}
