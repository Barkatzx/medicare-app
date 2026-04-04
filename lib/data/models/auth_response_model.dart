import '../../domain/entities/user_entity.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserEntity? user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? UserEntity.fromJson(json['user']) : null,
    );
  }
}
