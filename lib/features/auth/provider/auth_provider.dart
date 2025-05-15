// lib/core/providers/auth_provider.dart
import 'package:flutter/foundation.dart';

import '/features/auth/provider/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;
  bool _isLoggedIn = false;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      final result = await _authService.login(username, password);

      if (result['success'] == true) {
        _isLoggedIn = true;
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _errorCode = result['code'] ?? 'unknown_error';
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _errorCode = 'system_error';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<String?> getUserEmail() async {
    return await _authService.getUserEmail();
  }

  Future<String?> getUserAvatarUrl() async {
    return await _authService.getUserAvatarUrl();
  }

  Future<String?> getUserDisplayName() async {
    return await _authService.getUserDisplayName();
  }
}
