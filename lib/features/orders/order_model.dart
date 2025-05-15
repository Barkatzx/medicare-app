// lib/features/orders/order_model.dart
class BillingDetails {
  final String firstName;
  final String lastName;
  final String country;
  final String address1;
  final String phone;
  final String email;

  BillingDetails({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.address1,
    required this.phone,
    required this.email,
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      country: json['country'] ?? '',
      address1: json['address_1'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  static BillingDetails empty() => BillingDetails(
    firstName: '',
    lastName: '',
    country: '',
    address1: '',
    phone: '',
    email: '',
  );
}

class Order {
  final int id;
  final String number;
  final DateTime dateCreated;
  final String status;
  final String total;
  final String paymentMethod;
  final List<OrderItem> items;
  final BillingDetails? billing;
  final ShippingDetails? shipping;

  Order({
    required this.id,
    required this.number,
    required this.dateCreated,
    required this.status,
    required this.total,
    required this.paymentMethod,
    required this.items,
    this.billing,
    this.shipping,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      number: json['number'],
      dateCreated: DateTime.parse(json['date_created']),
      status: json['status'],
      total: json['total'],
      paymentMethod: json['payment_method_title'] ?? 'N/A',
      items:
          (json['line_items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      billing:
          json['billing'] != null
              ? BillingDetails.fromJson(json['billing'])
              : null,
      shipping:
          json['shipping'] != null
              ? ShippingDetails.fromJson(json['shipping'])
              : null,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final String price;
  final String total;
  final String? imageUrl;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toString(),
      total: json['total'].toString(),
      imageUrl: json['image']?['src'],
    );
  }
}

class ShippingDetails {
  final String firstName;
  final String lastName;
  final String address1;
  final String city;
  final String state;
  final String postcode;
  final String country;

  ShippingDetails({
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
  });

  factory ShippingDetails.fromJson(Map<String, dynamic> json) {
    return ShippingDetails(
      firstName: json['first_name'],
      lastName: json['last_name'],
      address1: json['address_1'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
    );
  }
}
