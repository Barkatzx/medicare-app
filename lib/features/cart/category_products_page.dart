import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/core/config/api_config.dart';
import '../cart/cart_provider.dart';
import '../cart/product_model.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Future<List<Product>> Function() fetchProducts;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.fetchProducts,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _perPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchProductsPage(int page) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/products?category=${widget.categoryId}&page=$page&per_page=$_perPage',
    );
    final response = await http.get(
      url,
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

  Future<void> _loadInitialProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _fetchProductsPage(1);
      setState(() {
        _products = products;
        _isLoading = false;
        _hasMore = products.length == _perPage;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final nextPage = _page + 1;
      final newProducts = await _fetchProductsPage(nextPage);

      setState(() {
        _page = nextPage;
        _isLoading = false;
        _products.addAll(newProducts);
        _hasMore = newProducts.length == _perPage;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load more products: $e')),
      );
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _products = [];
      _page = 1;
      _hasMore = true;
    });
    await _loadInitialProducts();
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final hasDiscount = product.onSale && product.regularPrice != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child:
                      product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.shopping_bag, color: Colors.grey),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.categoryName != null)
                      Text(
                        product.categoryName!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),

                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        if (hasDiscount)
                          Text(
                            '\$${product.regularPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),

                        if (hasDiscount) const SizedBox(width: 6),

                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: hasDiscount ? Colors.indigo : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (hasDiscount) const SizedBox(width: 6),

                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '- ${((product.regularPrice! - product.price) / product.regularPrice! * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.indigo, size: 20),
                ),
                onPressed: () {
                  cartProvider.addItem(
                    productId: product.id,
                    name: product.name,
                    price: product.price,
                    regularPrice: product.regularPrice,
                    onSale: product.onSale,
                    imageUrl: product.imageUrl,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${product.name} to cart'),
                      backgroundColor: Colors.green[400],
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: const Color(0xFF6C63FF),
        child:
            _products.isEmpty && !_isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 72,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Products Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This category currently has no products',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _products.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _products.length) {
                      return _hasMore
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox();
                    }
                    return _buildProductItem(context, _products[index]);
                  },
                ),
      ),
    );
  }
}
