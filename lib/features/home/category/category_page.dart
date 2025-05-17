import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/core/config/api_config.dart';
import '/features/cart/category_products_page.dart';
import '/features/cart/product_model.dart';

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'],
      imageUrl: json['image']?['src'] ?? '',
      productCount: json['count'] ?? 0,
    );
  }
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/categories?per_page=100'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'))}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categories =
              data
                  .map((json) => Category.fromJson(json))
                  .where(
                    (cat) =>
                        cat.name.toLowerCase() != 'uncategorized' &&
                        cat.productCount > 0,
                  )
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load categories (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Implement pagination if needed
    }
  }

  Future<List<Product>> _fetchProductsByCategory(String categoryId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products?category=$categoryId'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'))}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _navigateToCategoryProducts(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CategoryProductsPage(
              categoryId: category.id,
              categoryName: category.name,
              fetchProducts: () => _fetchProductsByCategory(category.id),
            ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCategoryProducts(context, category),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              // Image on left
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      category.imageUrl.isNotEmpty
                          ? Image.network(
                            category.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => _buildPlaceholderIcon(),
                          )
                          : _buildPlaceholderIcon(),
                ),
              ),
              const SizedBox(width: 16),

              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Product count
                    Text(
                      '${category.productCount} products',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron icon
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.category, size: 30, color: Colors.grey),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load categories',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No categories available'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchCategories,
        child:
            _isLoading
                ? _buildLoadingState()
                : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _categories.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(_categories[index]);
                  },
                ),
      ),
    );
  }
}
