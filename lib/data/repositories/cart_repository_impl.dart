import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/cart_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/cart_entity.dart';
import '../datasources/local/shared_prefs_helper.dart';

class CartRepositoryImpl implements CartRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  CartRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<CartEntity> getCart() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('Getting cart from: ${ApiConstants.cart}');

      final response = await client
          .get(
            Uri.parse(ApiConstants.cart),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      print('Cart response status: ${response.statusCode}');
      print('Cart response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Parsed response: $responseData');

        // Check if response has data wrapper
        if (responseData['data'] != null && responseData['success'] == true) {
          return CartEntity.fromJson(responseData['data']);
        } else {
          return CartEntity.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to load cart');
      }
    } catch (e) {
      print('Get cart error: $e');
      throw Exception('Error loading cart: $e');
    }
  }

  @override
  Future<int> getCartCount() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        return 0;
      }

      final response = await client
          .get(
            Uri.parse(ApiConstants.cart),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return responseData['data']['itemCount'] ?? 0;
        }
        return 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Get cart count error: $e');
      return 0;
    }
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final requestBody = {'productId': productId, 'quantity': quantity};

      print('Adding to cart - URL: ${ApiConstants.addToCart}');
      print('Request body: $requestBody');

      final response = await client
          .post(
            Uri.parse(ApiConstants.addToCart),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode(requestBody),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      print('Add to cart response status: ${response.statusCode}');
      print('Add to cart response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      print('Add to cart error: $e');
      throw Exception('Error adding to cart: $e');
    }
  }

  @override
  Future<void> updateCartItem(String itemId, int quantity) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final requestBody = {'quantity': quantity};

      final response = await client
          .put(
            Uri.parse(ApiConstants.cartItem(itemId)),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode(requestBody),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update cart item');
      }
    } catch (e) {
      print('Update cart item error: $e');
      throw Exception('Error updating cart item: $e');
    }
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .delete(
            Uri.parse(ApiConstants.cartItem(itemId)),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to remove from cart');
      }
    } catch (e) {
      print('Remove from cart error: $e');
      throw Exception('Error removing from cart: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .delete(
            Uri.parse(ApiConstants.clearCart),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      print('Clear cart error: $e');
      throw Exception('Error clearing cart: $e');
    }
  }
}
