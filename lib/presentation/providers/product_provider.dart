import 'package:flutter/material.dart';
import 'package:medicare_app/data/repositories/product_repository.dart';
import '../../domain/entities/product_entity.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider({required this.productRepository});

  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<ProductEntity> get products =>
      _searchQuery.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> loadProducts() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _products = await productRepository.getProducts();
      _filteredProducts = _products;
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredProducts = _products;
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _filteredProducts = await productRepository.searchProducts(query);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = _products;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
