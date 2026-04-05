import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/cart_repository.dart';
import '../../domain/entities/cart_entity.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository cartRepository;

  CartProvider({required this.cartRepository});

  CartEntity? _cart;
  bool _isLoading = false;
  int _cartItemCount = 0;

  CartEntity? get cart => _cart;
  bool get isLoading => _isLoading;
  int get cartItemCount => _cartItemCount;
  List<CartItemEntity> get cartItems => _cart?.items ?? [];
  double get totalAmount => _cart?.totalAmount ?? 0.0;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cart = await cartRepository.getCart();
      _cartItemCount = _cart?.totalItems ?? 0;
    } catch (e) {
      print('Error loading cart: $e');
      _cart = null;
      _cartItemCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCartCount() async {
    try {
      _cartItemCount = await cartRepository.getCartCount();
      notifyListeners();
    } catch (e) {
      print('Error loading cart count: $e');
      _cartItemCount = 0;
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await cartRepository.addToCart(productId, quantity);
      await loadCartCount();
      await loadCart();
      notifyListeners();
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await cartRepository.updateCartItem(itemId, quantity);
      await loadCartCount();
      await loadCart();
      notifyListeners();
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await cartRepository.removeFromCart(itemId);
      await loadCartCount();
      await loadCart();
      notifyListeners();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await cartRepository.clearCart();
      await loadCartCount();
      await loadCart();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }
}
