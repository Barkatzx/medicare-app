import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicare/features/cart/cart_provider.dart';
import 'package:provider/provider.dart';

import '/core/config/api_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
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
    fetchProducts();
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
      fetchMoreProducts();
    }
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        products = [];
        page = 1;
        hasMore = true;
        errorMessage = '';
      });
    }
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final credentials = base64Encode(
        utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'),
      );
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.productsEndpoint}?featured=true&per_page=$perPage&page=1',
        ),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> allProducts = json.decode(response.body);
        setState(() {
          products = allProducts;
          isLoading = false;
          hasMore = allProducts.length == perPage;
          page = 2;
        });
      } else {
        setState(() {
          errorMessage =
              'Error: ${response.statusCode} - ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load products: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreProducts() async {
    if (!hasMore) return;
    setState(() {
      isLoadingMore = true;
    });
    try {
      final credentials = base64Encode(
        utf8.encode('${ApiConfig.consumerKey}:${ApiConfig.consumerSecret}'),
      );
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.productsEndpoint}?featured=true&per_page=$perPage&page=$page',
        ),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> moreProducts = json.decode(response.body);
        setState(() {
          products.addAll(moreProducts);
          isLoadingMore = false;
          hasMore = moreProducts.length == perPage;
          page++;
        });
      } else {
        setState(() {
          isLoadingMore = false;
          hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
        hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    return RefreshIndicator(
      onRefresh: () => fetchProducts(refresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                'Most Discounted Product',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(product: products[index]),
                childCount: products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            ),
          ),
          // Loading indicator at the bottom
          if (isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product['images'] != null &&
                product['images'].isNotEmpty &&
                product['images'][0]['src'] != null
            ? product['images'][0]['src']
            : '';
    final title = product['name'] ?? 'No Name';

    final sellingPrice =
        double.tryParse(product['price']?.toString() ?? '0') ?? 0;

    final regularPriceStr = product['regular_price']?.toString() ?? '';
    final double? regularPriceVal =
        regularPriceStr.isNotEmpty ? double.tryParse(regularPriceStr) : null;

    double discountPercent = 0;
    if (regularPriceVal != null && regularPriceVal > sellingPrice) {
      discountPercent =
          ((regularPriceVal - sellingPrice) / regularPriceVal) * 100;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // TODO: Navigate to product detail if needed
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image),
                                  ),
                            )
                            : Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image)),
                            ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (regularPriceVal != null &&
                              regularPriceVal > sellingPrice)
                            Text(
                              '৳${regularPriceVal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (regularPriceVal != null &&
                              regularPriceVal > sellingPrice)
                            const SizedBox(width: 6),
                          Text(
                            '৳${sellingPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addItem(
                              productId: product['id'].toString(),
                              name: title,
                              imageUrl: imageUrl,
                              price: sellingPrice,
                              regularPrice: regularPriceVal,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added "$title" to cart')),
                            );
                          },
                          child: const Text('Add Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (discountPercent > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${discountPercent.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
