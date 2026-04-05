class ApiConstants {
  ApiConstants._();

  // ✅ Single Railway URL for all platforms since it's deployed
  static const String baseUrl =
      'https://medicare-server-production.up.railway.app';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==================== AUTHENTICATION ROUTES ====================
  static String get register => '$baseUrl/api/users/register';
  static String get login => '$baseUrl/api/users/login';
  static String get verifyAuth => '$baseUrl/api/users/verify-auth';

  // ==================== USER PROFILE ROUTES ====================
  static String get profile => '$baseUrl/api/users/profile';
  static String get changePassword => '$baseUrl/api/users/change-password';

  // ==================== ADDRESS ROUTES ====================
  static String get addresses => '$baseUrl/api/users/addresses';
  static String addressDefault(String addressId) =>
      '$baseUrl/api/users/addresses/$addressId/default';
  static String addressDetail(String addressId) =>
      '$baseUrl/api/users/addresses/$addressId';

  // ==================== CART ROUTES ====================
  static String get cart => '$baseUrl/api/users/cart';
  static String get cartCount => '$baseUrl/api/users/cart/count';
  static String get addToCart => '$baseUrl/api/users/cart/add';
  static String cartItem(String itemId) =>
      '$baseUrl/api/users/cart/item/$itemId';
  static String get clearCart => '$baseUrl/api/users/cart/clear';

  // ==================== NOTIFICATION ROUTES ====================
  static String get notifications => '$baseUrl/api/users/notifications';
  static String get markAllRead => '$baseUrl/api/users/notifications/read-all';
  static String markNotificationRead(String notificationId) =>
      '$baseUrl/api/users/notifications/$notificationId/read';

  // ==================== PRODUCT ROUTES ====================
  static String get products => '$baseUrl/api/products';
  static String get productsOnSale => '$baseUrl/api/products/on-sale';
  static String get searchProducts => '$baseUrl/api/products/search';
  static String productDetail(String id) => '$baseUrl/api/products/$id';

  // ==================== CATEGORY ROUTES ====================
  static String get categories => '$baseUrl/api/categories';
  static String categoryDetail(String id) => '$baseUrl/api/categories/$id';
  static String categoryProducts(String id) =>
      '$baseUrl/api/categories/$id/products';

  // ==================== ORDER ROUTES ====================
  static String get createOrder => '$baseUrl/api/orders';
  static String get myOrders => '$baseUrl/api/orders/my-orders';
  static String myOrderDetail(String orderId) =>
      '$baseUrl/api/orders/my-orders/$orderId';
  static String cancelOrder(String orderId) =>
      '$baseUrl/api/orders/$orderId/cancel';

  // ==================== HTTP METHODS ====================
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';

  // ==================== HEADERS ====================
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
