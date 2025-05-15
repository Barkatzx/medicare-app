// lib/features/orders/order_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/core/config/api_config.dart';
import '/features/auth/provider/auth_provider.dart';
import '/features/orders/order_model.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final email = await authProvider.getUserEmail();

      if (email == null) {
        throw Exception('User email not found');
      }

      // Step 1: Get customer ID
      final customerUrl = '${ApiConfig.customersEndpoint}?email=$email';

      final customerResponse = await http.get(
        Uri.parse(customerUrl),
        headers: _getAuthHeaders(),
      );

      if (customerResponse.statusCode != 200) {
        throw Exception('Failed to fetch customer data');
      }

      final customers = json.decode(customerResponse.body) as List;
      if (customers.isEmpty) throw Exception('Customer not found');

      final customerId = customers.first['id'];

      // Step 2: Fetch orders by customer ID
      final ordersUrl = '${ApiConfig.ordersEndpoint}?customer=$customerId';

      final orderResponse = await http.get(
        Uri.parse(ordersUrl),
        headers: _getAuthHeaders(),
      );

      List<Order> fetchedOrders = [];

      if (orderResponse.statusCode == 200) {
        final ordersJson = json.decode(orderResponse.body) as List;

        if (ordersJson.isEmpty) {
          // Step 3: Fallback to search by email
          final searchUrl = '${ApiConfig.ordersEndpoint}?search=$email';

          final searchResponse = await http.get(
            Uri.parse(searchUrl),
            headers: _getAuthHeaders(),
          );

          if (searchResponse.statusCode == 200) {
            final searchOrdersJson = json.decode(searchResponse.body) as List;
            fetchedOrders =
                searchOrdersJson.map((json) => Order.fromJson(json)).toList();
          } else {
            throw Exception(
              'Failed to fetch fallback orders: ${searchResponse.statusCode}',
            );
          }
        } else {
          fetchedOrders =
              ordersJson.map((json) => Order.fromJson(json)).toList();
        }

        _orders = fetchedOrders;
        _error = null;
      } else {
        throw Exception('Failed to load orders: ${orderResponse.statusCode}');
      }
    } catch (e) {
      _orders = [];
      _error = 'Error fetching orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, String> _getAuthHeaders() {
    final auth = '${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}';
    return {
      'Authorization': 'Basic ${base64Encode(utf8.encode(auth))}',
      'Content-Type': 'application/json',
    };
  }
}
