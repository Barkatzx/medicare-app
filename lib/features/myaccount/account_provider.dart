// lib/features/account/account_provider.dart
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '/features/myaccount/user_model.dart';
import '/features/auth/provider/auth_provider.dart';

class AccountProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Get basic user info from AuthService
      final email = await authProvider.getUserEmail();
      final displayName = await authProvider.getUserDisplayName();
      final phone = await authProvider.getUserPhone();
      final avatarUrl = await authProvider.getUserAvatarUrl();

      if (email == null) {
        throw Exception('User email not found');
      }

      // Create temporary user model
      _user = UserModel(
        id: 0, // Will be updated from API
        name: displayName ?? 'User',
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        username: email.split('@').first,
      );

      // Here you would add API calls to get additional user data
      // For example:
      // final customerData = await _fetchCustomerData(authProvider, email);
      // _user = _user!.copyWith(phone: customerData.phone, ...);

      _error = null;
    } catch (e) {
      _error = 'Error fetching user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(
    BuildContext context, {
    String? name,
    String? phone,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_user == null || !authProvider.isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Here you would add API calls to update user data
      // For example:
      // await _updateCustomerData(authProvider, name: name, phone: phone);

      // Update local user model
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        phone: phone ?? _user!.phone,
      );

      _error = null;
    } catch (e) {
      _error = 'Error updating profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
