// lib/features/account/account_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/core/config/api_config.dart';
import '/features/auth/provider/auth_provider.dart';
import '/features/myaccount/user_model.dart';

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

      if (email == null) {
        throw Exception('User email not found');
      }

      // First create temporary user model with basic info
      _user = UserModel(
        id: 0, // Will be updated from API
        name: displayName ?? 'User',
        email: email,
        username: email.split('@').first,
        billingDetails: BillingDetails.empty(),
      );

      // Fetch complete customer data from WooCommerce
      final customerData = await _fetchWooCommerceCustomerData(email);

      // Create billing details
      final billing = BillingDetails(
        firstName: customerData['billing']['first_name'] ?? '',
        lastName: customerData['billing']['last_name'] ?? '',
        country: customerData['billing']['country'] ?? '',
        address1: customerData['billing']['address_1'] ?? '',
        phone: customerData['billing']['phone'] ?? '',
        email: customerData['billing']['email'] ?? email,
      );

      // Update user model with all customer details
      _user = _user!.copyWith(
        id: customerData['id'] ?? 0,
        phone: customerData['billing']['phone'],
        billingDetails: billing,
      );

      _error = null;
    } catch (e) {
      _error = 'Error fetching user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _fetchWooCommerceCustomerData(
    String email,
  ) async {
    final url = '${ApiConfig.customersEndpoint}?email=$email';
    print('Fetching customer data from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'))}',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Add this to see the raw data

    if (response.statusCode == 200) {
      final customers = json.decode(response.body) as List;
      if (customers.isNotEmpty) {
        return customers.first as Map<String, dynamic>;
      }
      throw Exception('Customer not found');
    } else {
      throw Exception('Failed to load customer data: ${response.statusCode}');
    }
  }

  Future<void> updateUserProfile(
    BuildContext context, {
    String? firstName,
    String? lastName,
    String? phone,
    String? country,
    String? address1,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_user == null || !authProvider.isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Get current billing details
      final currentBilling = _user!.billingDetails ?? BillingDetails.empty();

      // Prepare the update data for WooCommerce
      final updateData = {
        'first_name': firstName ?? currentBilling.firstName,
        'last_name': lastName ?? currentBilling.lastName,
        'billing': {
          'first_name': firstName ?? currentBilling.firstName,
          'last_name': lastName ?? currentBilling.lastName,
          'phone': phone ?? currentBilling.phone,
          'country': country ?? currentBilling.country,
          'address_1': address1 ?? currentBilling.address1,
          'email': _user!.email,
        },
      };

      // Update customer data in WooCommerce
      await _updateWooCommerceCustomerData(_user!.id, updateData);

      // Create updated billing details
      final updatedBilling = currentBilling.copyWith(
        firstName: firstName ?? currentBilling.firstName,
        lastName: lastName ?? currentBilling.lastName,
        phone: phone ?? currentBilling.phone,
        country: country ?? currentBilling.country,
        address1: address1 ?? currentBilling.address1,
      );

      // Update local user model
      _user = _user!.copyWith(
        phone: phone ?? _user!.phone,
        billingDetails: updatedBilling,
      );

      _error = null;
    } catch (e) {
      _error = 'Error updating profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateWooCommerceCustomerData(
    int customerId,
    Map<String, dynamic> data,
  ) async {
    final url = '${ApiConfig.customersEndpoint}/$customerId';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'))}',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update customer: ${response.statusCode}');
    }
  }

  Future<void> clearUserData() async {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
