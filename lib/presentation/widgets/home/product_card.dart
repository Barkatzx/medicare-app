import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import '../../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

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
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: const Color(0xFFF2F2F2),
                              child: const Icon(
                                Icons.medical_services,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 100,
                          color: const Color(0xFFF2F2F2),
                          child: const Icon(
                            Icons.medical_services,
                            size: 40,
                            color: Colors.grey,
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
                      style: CustomTextStyle.bodySmall,
                    ),
                    SizedBox(height: CustomTheme.spacingXS),

                    // Product Name
                    Text(
                      product.name,
                      style: CustomTextStyle.bodyLarge.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: CustomTheme.spacingSM),

                    // Price Section
                    if (product.discountedPrice != null) ...[
                      Row(
                        children: [
                          Text(
                            '\$${product.finalPrice.toStringAsFixed(2)}',
                            style: CustomTextStyle.heading3.copyWith(
                              color: CustomTheme.primaryColor,
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
                          borderRadius: BorderRadius.circular(
                            CustomTheme.radiusSM,
                          ),
                        ),
                        child: Text(
                          product.discountBadge ??
                              '${product.discountPercent}% OFF',
                          style: TextStyle(
                            color: CustomTheme.errorColor,
                            fontSize: CustomTheme.fontSizeXS,
                            fontWeight: CustomTheme.fontWeightBold,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: CustomTextStyle.heading3.copyWith(
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Third Flex Box - Cart Icon
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
