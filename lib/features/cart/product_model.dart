// lib/features/products/product_model.dart
class Product {
  final String id;
  final String name;
  final double price;
  final double? regularPrice;
  final String imageUrl;
  final bool onSale;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.regularPrice,
    required this.imageUrl,
    this.onSale = false,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final price = double.tryParse(json['price'] ?? '0') ?? 0.0;
    double? regularPrice;
    final onSale = json['on_sale'] ?? false;

    if (onSale && json['regular_price'] != null) {
      regularPrice = double.tryParse(json['regular_price']);
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Product',
      price: price,
      regularPrice: regularPrice,
      imageUrl:
          json['images']?.isNotEmpty == true ? json['images'][0]['src'] : '',
      onSale: onSale,
      categoryName:
          json['categories']?.isNotEmpty == true
              ? json['categories'][0]['name']
              : null,
    );
  }
}
