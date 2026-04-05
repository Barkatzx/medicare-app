class CartEntity {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double totalAmount;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartEntity.fromJson(Map<String, dynamic> json) {
    return CartEntity(
      id: json['id'] ?? json['_id'],
      userId: json['userId'],
      items: (json['items'] as List? ?? [])
          .map((item) => CartItemEntity.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalItems: json['totalItems'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CartItemEntity {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double? discountedPrice;
  final int quantity;
  final double totalPrice;

  CartItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.discountedPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      id: json['id'] ?? json['_id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'] ?? '',
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice'] as num).toDouble()
          : null,
      quantity: json['quantity'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'discountedPrice': discountedPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  double get itemFinalPrice {
    return discountedPrice ?? price;
  }

  double get itemSavings {
    return discountedPrice != null ? price - discountedPrice! : 0;
  }
}
