import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthProvider({required this.loginUseCase, required this.registerUseCase});

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await loginUseCase.execute(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await registerUseCase.execute(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Add this method to the AuthProvider class
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
