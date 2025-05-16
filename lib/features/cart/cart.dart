import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/cart/cart_provider.dart';
import '/features/cart/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Cart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Text(
                  '${cart.itemCount} items',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          items.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: items.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            height: 8,
                            color: Colors.transparent,
                          ),
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        return _buildCartItem(item, cart, context);
                      },
                    ),
                  ),
                  _buildTotalSection(context, cart),
                ],
              ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse products and add to cart',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    CartItem item,
    CartProvider cart,
    BuildContext context,
  ) {
    // Simplify discount calculation logic
    final bool hasDiscount =
        item.regularPrice != null && item.regularPrice! > item.price;
    final double amountSaved =
        hasDiscount ? (item.regularPrice! - item.price) * item.quantity : 0;
    final double discountPercent =
        hasDiscount
            ? ((item.regularPrice! - item.price) / item.regularPrice!) * 100
            : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(2),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFf5f5f5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  item.imageUrl.isNotEmpty
                      ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                              ),
                            ),
                      )
                      : Center(
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          '৳${item.regularPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        '৳${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '-${discountPercent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasDiscount)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'You save ৳${amountSaved.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        onPressed:
                            () =>
                                item.quantity > 1
                                    ? cart.decreaseQuantity(item.id)
                                    : cart.removeItem(item.id),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 30,
                        child: Text(
                          item.quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 5),
                      _quantityButton(
                        icon: Icons.add,
                        onPressed: () => cart.increaseQuantity(item.id),
                      ),
                      const Spacer(),
                      _quantityButton(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onPressed: () => cart.removeItem(item.id),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: color ?? Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, CartProvider cart) {
    final hasSavings = cart.totalSaved > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          if (hasSavings) ...[
            Row(
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const Spacer(),
                Text(
                  '৳${cart.totalOriginalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text(
                  'Discount:',
                  style: TextStyle(fontSize: 15, color: Colors.green),
                ),
                const Spacer(),
                Text(
                  '-৳${cart.totalSaved.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15, color: Colors.green),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '৳${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: false).push(
                  MaterialPageRoute(builder: (context) => const CheckoutPage()),
                );
              },
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
