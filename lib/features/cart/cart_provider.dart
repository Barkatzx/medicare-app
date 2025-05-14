import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/core/config/api_config.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final double? regularPrice;
  final int quantity;
  final String imageUrl;
  final bool onSale;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.regularPrice,
    required this.quantity,
    required this.imageUrl,
    this.onSale = false,
  });

  double? get discountPercentage {
    if (regularPrice != null && regularPrice! > price && onSale) {
      return ((regularPrice! - price) / regularPrice!) * 100;
    }
    return null;
  }

  double get amountSaved {
    if (regularPrice != null && regularPrice! > price && onSale) {
      return (regularPrice! - price) * quantity;
    }
    return 0.0;
  }
}

class CartProvider with ChangeNotifier {
  void clearCart() {
    // Logic to clear the cart
    _items.clear();
    notifyListeners();
  }

  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double get totalOriginalAmount {
    return _items.values.fold(0.0, (sum, item) {
      return sum + ((item.regularPrice ?? item.price) * item.quantity);
    });
  }

  double get totalSaved => totalOriginalAmount - totalAmount;

  Future<void> addItemFromWooProduct(String productId) async {
    try {
      if (_items.containsKey(productId)) {
        increaseQuantity(productId);
        return;
      }

      final url = Uri.parse(
        '${ApiConfig.productsEndpoint}/$productId?consumer_key=${ApiConfig.consumerKey}&consumer_secret=${ApiConfig.consumerSecret}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final productData = json.decode(response.body);

        // Debug print to check API response
        debugPrint('Product Data: $productData');

        double price = double.tryParse(productData['price'] ?? '0') ?? 0.0;
        double? regularPrice;
        bool onSale = productData['on_sale'] ?? false;

        if (onSale && productData['regular_price'] != null) {
          regularPrice = double.tryParse(productData['regular_price']);
        }

        String imageUrl = '';
        if (productData['images'] != null && productData['images'].isNotEmpty) {
          imageUrl = productData['images'][0]['src'] ?? '';
        }

        _items.putIfAbsent(
          productId,
          () => CartItem(
            id: productId,
            name: productData['name'] ?? 'Unknown Product',
            price: price,
            regularPrice: regularPrice,
            quantity: 1,
            imageUrl: imageUrl,
            onSale: onSale,
          ),
        );

        notifyListeners();
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error adding product to cart: $error');
      rethrow;
    }
  }

  void addItem({
    required String productId,
    required String name,
    required double price,
    double? regularPrice,
    bool onSale = false,
    required String imageUrl,
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          regularPrice: existing.regularPrice,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
          onSale: existing.onSale,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          price: price,
          regularPrice: regularPrice,
          quantity: 1,
          imageUrl: imageUrl,
          onSale: onSale,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          regularPrice: existing.regularPrice,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
          onSale: existing.onSale,
        ),
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existing) => CartItem(
            id: existing.id,
            name: existing.name,
            price: existing.price,
            regularPrice: existing.regularPrice,
            quantity: existing.quantity - 1,
            imageUrl: existing.imageUrl,
            onSale: existing.onSale,
          ),
        );
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
