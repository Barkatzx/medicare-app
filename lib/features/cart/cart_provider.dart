import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? regularPrice; // optional regular price for discount display
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.regularPrice,
    this.quantity = 1,
  });

  // ✅ Proper placement inside the class
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      imageUrl: imageUrl,
      price: price,
      regularPrice: regularPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.values.fold(
    0.0,
    (sum, item) => sum + (item.price * item.quantity),
  );

  void addItem({
    required String productId,
    required String name,
    required String imageUrl,
    required double price,
    double? regularPrice,
  }) {
    if (_items.containsKey(productId)) {
      increaseQuantity(productId);
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          imageUrl: imageUrl,
          price: price,
          regularPrice: regularPrice,
        ),
      );
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => existing.copyWith(quantity: existing.quantity + 1),
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    final currentQuantity = _items[productId]!.quantity;
    if (currentQuantity > 1) {
      _items.update(
        productId,
        (existing) => existing.copyWith(quantity: existing.quantity - 1),
      );
    } else {
      removeItem(productId);
      return;
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void setQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => existing.copyWith(quantity: newQuantity),
      );
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool containsItem(String productId) => _items.containsKey(productId);

  int getQuantity(String productId) => _items[productId]?.quantity ?? 0;
}
