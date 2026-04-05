import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/providers/cart_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail', arguments: product.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: CustomTheme.spacingMD),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
          boxShadow: CustomTheme.boxShadowLight,
        ),
        child: Padding(
          padding: EdgeInsets.all(CustomTheme.spacingMD),
          child: Row(
            children: [
              // First Flex Box - Product Image
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first.url,
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 80,
                              color: CustomTheme.secondaryColor.withOpacity(
                                0.1,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 80,
                              color: CustomTheme.secondaryColor.withOpacity(
                                0.1,
                              ),
                              child: Icon(
                                Icons.medical_services,
                                size: 35,
                                color: CustomTheme.secondaryColor,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 80,
                          color: CustomTheme.secondaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.medical_services,
                            size: 35,
                            color: CustomTheme.secondaryColor,
                          ),
                        ),
                ),
              ),
              SizedBox(width: CustomTheme.spacingMD),

              // Second Flex Box - Product Details
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name
                    Text(
                      product.categoryName,
                      style: CustomTextStyle.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: CustomTheme.spacingXS),

                    // Product Name
                    Text(
                      product.name,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: CustomTheme.spacingSM),

                    // Price Section
                    _buildPriceSection(),
                  ],
                ),
              ),

              // Third Flex Box - Cart Icon with Instant Add
              Expanded(flex: 1, child: _AddToCartButton(product: product)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    if (product.discountedPrice != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '\$${product.finalPrice.toStringAsFixed(2)}',
                style: CustomTextStyle.heading3.copyWith(
                  color: CustomTheme.primaryColor,
                  fontWeight: CustomTheme.fontWeightBold,
                ),
              ),
              SizedBox(width: CustomTheme.spacingSM),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: CustomTextStyle.bodySmall.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          SizedBox(height: CustomTheme.spacingXS),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: CustomTheme.spacingSM,
              vertical: CustomTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: CustomTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
            ),
            child: Text(
              product.discountBadge ?? '${product.discountPercent}% OFF',
              style: TextStyle(
                color: CustomTheme.errorColor,
                fontSize: CustomTheme.fontSizeXS,
                fontWeight: CustomTheme.fontWeightBold,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: CustomTextStyle.heading3.copyWith(
          color: CustomTheme.primaryColor,
          fontWeight: CustomTheme.fontWeightBold,
        ),
      );
    }
  }
}

// Separate Stateful Widget for Add to Cart Button to handle local state
class _AddToCartButton extends StatefulWidget {
  final ProductEntity product;

  const _AddToCartButton({required this.product});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _isAdding = false;

  Future<void> _addToCart(CartProvider cartProvider) async {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
    });

    // Don't await - fire and forget for instant UI
    cartProvider
        .addToCart(widget.product.id, 1)
        .then((success) {
          if (mounted) {
            setState(() {
              _isAdding = false;
            });

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.product.name} added to cart',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: CustomTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                  ),
                ),
              );
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isAdding = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => _addToCart(cartProvider),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isAdding
              ? CustomTheme.primaryColor.withOpacity(0.5)
              : CustomTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
        ),
        child: _isAdding
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomTheme.primaryColor,
                ),
              )
            : Icon(
                Icons.shopping_cart_outlined,
                size: 20,
                color: CustomTheme.primaryColor,
              ),
      ),
    );
  }
}
