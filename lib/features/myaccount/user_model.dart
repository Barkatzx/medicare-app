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

  BillingDetails copyWith({
    String? firstName,
    String? lastName,
    String? country,
    String? address1,
    String? phone,
    String? email,
  }) {
    return BillingDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      address1: address1 ?? this.address1,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  static empty() {}
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String username;
  final BillingDetails? billingDetails;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.username,
    this.billingDetails,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? username,
    BillingDetails? billingDetails,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      billingDetails: billingDetails ?? this.billingDetails,
    );
  }
}
