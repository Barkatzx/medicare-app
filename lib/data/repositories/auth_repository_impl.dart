import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/auth_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/user_entity.dart';

import '../models/auth_response_model.dart';
import '../datasources/local/shared_prefs_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  AuthRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<UserEntity> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {'password': password};

      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestBody['phone_number'] = phoneNumber;
      }

      final response = await client.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.getHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(
          json.decode(response.body),
        );

        if (authResponse.success && authResponse.token != null) {
          await prefsHelper.saveToken(authResponse.token!);
          return authResponse.user!;
        } else {
          throw Exception(authResponse.message);
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      };

      final response = await client.post(
        Uri.parse(ApiConstants.register),
        headers: ApiConstants.getHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(
          json.decode(response.body),
        );

        if (authResponse.success && authResponse.token != null) {
          await prefsHelper.saveToken(authResponse.token!);
          return authResponse.user!;
        } else {
          throw Exception(authResponse.message);
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  @override
  Future<void> logout() async {
    await prefsHelper.clearToken();
    await prefsHelper.clearUserData();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await prefsHelper.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return await prefsHelper.getToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await prefsHelper.saveToken(token);
  }

  @override
  Future<void> clearToken() async {
    await prefsHelper.clearToken();
  }
}
