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
    final discountPercent = _calculateDiscount(regularPrice, sellingPrice);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showProductDetails(context),
        child: Stack(
          children: [
            // Product Image
            _buildProductImage(imageUrl),

            // Product Details
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildProductDetails(
                context,
                title,
                regularPrice,
                sellingPrice,
                discountPercent,
              ),
            ),

            // Discount Badge
            if (discountPercent > 0) _buildDiscountBadge(discountPercent),

            // Favorite Button
            Positioned(top: 8, left: 8, child: _buildFavoriteButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.surfaceVariant.withOpacity(0.6),
          ],
        ),
      ),
      child:
          imageUrl.isNotEmpty
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
              : _buildPlaceholderImage(),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    String title,
    double? regularPrice,
    double sellingPrice,
    int discountPercent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceDisplay(regularPrice, sellingPrice),
              _buildAddToCartButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay(double? regularPrice, double sellingPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (regularPrice != null && regularPrice > sellingPrice)
          Text(
            '৳${regularPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        Text(
          '৳${sellingPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _addToCart(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountBadge(int discountPercent) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
    );
  }

  Widget _buildFavoriteButton() {
    return CircleAvatar(
      backgroundColor: Colors.white.withOpacity(0.9),
      radius: 18,
      child: IconButton(
        icon: const Icon(Icons.favorite_border, size: 18),
        color: Colors.black,
        onPressed: () {}, // TODO: Implement favorite functionality
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.photo_library_outlined,
        size: 48,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
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
        content: Text('Added ${product['name']} to cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    // TODO: Implement product details navigation
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => ProductDetailsScreen(product: product),
    // ));
  }
}
