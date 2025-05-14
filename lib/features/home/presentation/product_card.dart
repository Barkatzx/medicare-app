// lib/ui/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/cart/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final ThemeData theme;

  const ProductCard({super.key, required this.product, required this.theme});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['images']?[0]?['src'] ?? '';
    final title = product['name'] ?? 'No Name';
    final sellingPrice =
        double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final regularPrice = double.tryParse(
      product['regular_price']?.toString() ?? '',
    );

    final discountPercent =
        regularPrice != null && regularPrice > sellingPrice
            ? ((regularPrice - sellingPrice) / regularPrice * 100).round()
            : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showProductDetails(context),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _buildPlaceholderImage(),
                            )
                            : _buildPlaceholderImage(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow(regularPrice, sellingPrice),
                      const SizedBox(height: 12),
                      _buildAddToCartButton(context),
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
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$discountPercent% OFF',
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

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.image_search,
        size: 48,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }

  Widget _buildPriceRow(double? regularPrice, double sellingPrice) {
    return Row(
      children: [
        if (regularPrice != null && regularPrice > sellingPrice)
          Text(
            '৳${regularPrice.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        if (regularPrice != null && regularPrice > sellingPrice)
          const SizedBox(width: 8),
        Text(
          '৳${sellingPrice.toStringAsFixed(2)}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => _addToCart(context),
        child: const Text(
          'Add to Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
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
        content: Text('Added ${product['name']} to cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    // TODO: Implement product details navigation
  }
}
