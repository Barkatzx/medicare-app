import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/cart/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['images']?[0]?['src'] ?? '';
    final title = product['name'] ?? 'No Name';
    final sellingPrice =
        double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final regularPrice = double.tryParse(
      product['regular_price']?.toString() ?? '',
    );
    final discountPercent = _calculateDiscount(regularPrice, sellingPrice);

    // Get first category name or fallback
    final List categories = product['categories'] ?? [];
    final String categoryName =
        categories.isNotEmpty
            ? categories[0]['name'] ?? 'Uncategorized'
            : 'Uncategorized';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(imageUrl),
              ),
            ),
            const SizedBox(width: 12),

            // Middle - Category, Title, Prices
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Discount
                  Row(
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (discountPercent > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '- $discountPercent%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Product Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Prices
                  Row(
                    children: [
                      Text(
                        '৳${sellingPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      if (regularPrice != null &&
                          regularPrice > sellingPrice) ...[
                        const SizedBox(width: 8),
                        Text(
                          '৳${regularPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Right side - Centered Add to Cart Button
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => _addToCart(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return imageUrl.isNotEmpty
        ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(Icons.medical_services, size: 30, color: Colors.grey),
    );
  }

  int _calculateDiscount(double? regularPrice, double sellingPrice) {
    return regularPrice != null && regularPrice > sellingPrice
        ? ((regularPrice - sellingPrice) / regularPrice * 100).round()
        : 0;
  }

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      productId: product['id'].toString(),
      name: product['name'] ?? 'Unknown Product',
      imageUrl: product['images']?[0]?['src'] ?? '',
      price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
      regularPrice: double.tryParse(product['regular_price']?.toString() ?? ''),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product['name']} to your bag'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
