class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final int discountPercent;
  final int stock;
  final String categoryId;
  final String categoryName;
  final List<ProductImage> images;
  final double finalPrice;
  final double savings;
  final String? discountBadge;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.discountPercent,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
    required this.images,
    required this.finalPrice,
    required this.savings,
    this.discountBadge,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] ?? 0,
      stock: json['stock'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['category']?['name'] ?? 'Uncategorized',
      images: (json['images'] as List? ?? [])
          .map((img) => ProductImage.fromJson(img))
          .toList(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
      discountBadge: json['discountBadge'],
    );
  }
}

class ProductImage {
  final String id;
  final String url;
  final String? altText;

  ProductImage({required this.id, required this.url, this.altText});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
      altText: json['altText'],
    );
  }
}
