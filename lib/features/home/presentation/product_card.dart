// lib/ui/widgets/product_card.dart
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

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image with border radius
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: _buildProductImage(imageUrl),
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Prices in same line
                    _buildPriceDisplay(regularPrice, sellingPrice),
                    const SizedBox(height: 5),

                    // Add to Cart Button
                    _buildAddToCartButton(context),
                  ],
                ),
              ),
            ],
          ),

          // Discount Badge at top right
          if (discountPercent > 0) _buildDiscountBadge(discountPercent),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      height: 120,
      color: const Color(0xFFF5F5F5), // #f5f5f5 background
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

  Widget _buildPriceDisplay(double? regularPrice, double sellingPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (regularPrice != null && regularPrice > sellingPrice)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              '৳${regularPrice.toStringAsFixed(2)}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        Text(
          '৳${sellingPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _addToCart(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '- $discountPercent% ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(child: Icon(Icons.photo_library_outlined, size: 50));
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
        content: Text('Added ${product['name']} to your cart'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}
