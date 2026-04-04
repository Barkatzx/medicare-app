class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? avatar;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.avatar,
    required this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
