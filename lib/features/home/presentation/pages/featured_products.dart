import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/core/config/api_config.dart';
import '/features/home/presentation/product_card.dart';

class FeaturedProductsScreen extends StatefulWidget {
  const FeaturedProductsScreen({Key? key}) : super(key: key);

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {
  List<dynamic> featuredProducts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String errorMessage = '';
  int page = 1;
  final int perPage = 16;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore &&
        !isLoading) {
      _fetchMoreProducts();
    }
  }

  Future<void> _fetchInitialProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.productsEndpoint}?featured=true&per_page=$perPage&page=1',
        ),
        headers: _getAuthHeaders(),
      );

      _handleProductResponse(response, initialLoad: true);
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (!hasMore) return;

    try {
      setState(() => isLoadingMore = true);

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.productsEndpoint}?featured=true&per_page=$perPage&page=$page',
        ),
        headers: _getAuthHeaders(),
      );

      _handleProductResponse(response);
    } catch (e) {
      _handleError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoadingMore = false);
      }
    }
  }

  Map<String, String> _getAuthHeaders() {
    final credentials = base64Encode(
      utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'),
    );
    return {
      'Authorization': 'Basic $credentials',
      'Content-Type': 'application/json',
    };
  }

  void _handleProductResponse(
    http.Response response, {
    bool initialLoad = false,
  }) {
    if (response.statusCode == 200) {
      final List<dynamic> newProducts = json.decode(response.body);
      setState(() {
        if (initialLoad) {
          featuredProducts = newProducts;
        } else {
          featuredProducts.addAll(newProducts);
        }
        hasMore = newProducts.length == perPage;
        page++;
        isLoading = false;
      });
    } else {
      _handleError('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        errorMessage = message;
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      featuredProducts = [];
      page = 1;
      hasMore = true;
    });
    await _fetchInitialProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Featured Products'), elevation: 0),
      body: _buildProductList(theme),
    );
  }

  Widget _buildProductList(ThemeData theme) {
    if (isLoading && featuredProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _fetchInitialProducts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: _refreshProducts,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductCard(product: featuredProducts[index]),
                );
              }, childCount: featuredProducts.length),
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (!hasMore && featuredProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: Center(
                  child: Text(
                    'You\'ve reached the end',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
