// lib/core/services/auth_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '/core/config/api_config.dart';
import '/features/myaccount/user_model.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client client;

  AuthService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // First try JWT authentication
      final jwtResponse = await _attemptJwtLogin(username, password);
      if (jwtResponse['success'] == true) {
        return jwtResponse;
      }

      // If JWT fails, fall back to WooCommerce authentication
      return await _attemptWcLogin(username, password);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your connection',
        'code': 'network_error',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> _attemptJwtLogin(
    String username,
    String password,
  ) async {
    final url = Uri.parse('${ApiConfig.authorization}jwt-auth/v1/token');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    final responseBody = _parseResponse(response);

    if (response.statusCode == 200) {
      await _storeAuthData(responseBody);
      return {'success': true};
    }

    return {
      'success': false,
      'message': responseBody['message'] ?? 'Authentication failed',
      'code': responseBody['code'] ?? 'auth_failed',
      'status': response.statusCode,
    };
  }

  Future<Map<String, dynamic>> _attemptWcLogin(
    String username,
    String password,
  ) async {
    final credentials = base64Encode(
      utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'),
    );

    // First verify credentials by fetching customer data
    final customersResponse = await client.get(
      Uri.parse(ApiConfig.customersEndpoint),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      },
    );

    if (customersResponse.statusCode != 200) {
      return {
        'success': false,
        'message': 'Failed to access customer data',
        'code': 'wc_access_denied',
        'status': customersResponse.statusCode,
      };
    }

    final customers = json.decode(customersResponse.body) as List;
    final customer = customers.firstWhere(
      (c) => c['email'] == username || c['username'] == username,
      orElse: () => null,
    );

    if (customer == null) {
      return {
        'success': false,
        'message': 'Customer not found',
        'code': 'customer_not_found',
      };
    }

    // In production, implement proper password verification here
    // This is just a placeholder for the concept
    final passwordValid = await _verifyWcPassword(username, password);
    if (!passwordValid) {
      return {
        'success': false,
        'message': 'Invalid password',
        'code': 'invalid_password',
      };
    }

    // Generate a token or use existing auth mechanism
    await _storeAuthData({
      'token': 'wc_${customer['id']}_${DateTime.now().millisecondsSinceEpoch}',
      'user_email': customer['email'],
      'user_display_name': '${customer['first_name']} ${customer['last_name']}',
    });

    return {'success': true};
  }

  Future<bool> _verifyWcPassword(String username, String password) async {
    // In a real app, implement proper password verification
    // This might involve calling a custom endpoint or using WP's auth system
    return true; // Placeholder - always returns true in this example
  }

  Future<BillingDetails?> fetchAndStoreBillingDetails(
    String userToken,
    int customerId,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.customersEndpoint}/$customerId?consumerKey=${ApiConfig.consumerKey}&consumerSecret=${ApiConfig.consumerSecret}',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final billing = data['billing'];

        if (billing != null) {
          final billingDetails = BillingDetails(
            firstName: billing['first_name'] ?? '',
            lastName: billing['last_name'] ?? '',
            country: billing['country'] ?? '',
            address1: billing['address_1'] ?? '',
            phone: billing['phone'] ?? '',
            email: billing['email'] ?? '',
          );
          await _storage.write(
            key: 'billing_first_name',
            value: billingDetails.firstName,
          );
          await _storage.write(
            key: 'billing_last_name',
            value: billingDetails.lastName,
          );
          await _storage.write(
            key: 'billing_country',
            value: billingDetails.country,
          );
          await _storage.write(
            key: 'billing_address1',
            value: billingDetails.address1,
          );
          await _storage.write(
            key: 'billing_phone',
            value: billingDetails.phone,
          );
          await _storage.write(
            key: 'billing_email',
            value: billingDetails.email,
          );

          return billingDetails;
        }
      } else {
        print('Failed to fetch billing details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching billing details: $e');
    }
    return null;
  }

  // Get billing details from storage
  Future<BillingDetails?> getStoredBillingDetails() async {
    final firstName = await _storage.read(key: 'billing_first_name');
    if (firstName == null) return null;

    return BillingDetails(
      firstName: firstName,
      lastName: await _storage.read(key: 'billing_last_name') ?? '',
      country: await _storage.read(key: 'billing_country') ?? '',
      address1: await _storage.read(key: 'billing_address1') ?? '',
      phone: await _storage.read(key: 'billing_phone') ?? '',
      email: await _storage.read(key: 'billing_email') ?? '',
    );
  }

  // Update billing details in storage
  Future<void> updateBillingDetails(BillingDetails details) async {
    await _storage.write(key: 'billing_first_name', value: details.firstName);
    await _storage.write(key: 'billing_last_name', value: details.lastName);
    await _storage.write(key: 'billing_country', value: details.country);
    await _storage.write(key: 'billing_address1', value: details.address1);
    await _storage.write(key: 'billing_phone', value: details.phone);
    await _storage.write(key: 'billing_email', value: details.email);
  }

  Future<void> _storeAuthData(Map<String, dynamic> data) async {
    await _storage.write(key: 'auth_token', value: data['token']);
    await _storage.write(key: 'user_email', value: data['user_email']);
    await _storage.write(
      key: 'user_display_name',
      value: data['user_display_name'] ?? 'User',
    );
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      return {'message': 'Invalid server response', 'code': 'invalid_response'};
    }
  }

  // Existing methods
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_display_name');
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    return await _storage.containsKey(key: 'auth_token');
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: 'user_email');
  }

  Future<String?> getUserAvatarUrl() async {
    return await _storage.read(key: 'user_avatarUrl');
  }

  Future<String?> getUserDisplayName() async {
    return await _storage.read(key: 'user_display_name');
  }
}
