class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';

  // ==================== AUTHENTICATION ROUTES ====================
  static const String register = '$baseUrl/api/users/register';
  static const String login = '$baseUrl/api/users/login';

  // ==================== USER PROFILE ROUTES ====================
  static const String profile = '$baseUrl/api/users/profile';
  static const String changePassword = '$baseUrl/api/users/change-password';

  // ==================== ADDRESS ROUTES ====================
  static const String addresses = '$baseUrl/api/users/addresses';
  static String addressDefault(String addressId) =>
      '$baseUrl/api/users/addresses/$addressId/default';
  static String addressDetail(String addressId) =>
      '$baseUrl/api/users/addresses/$addressId';

  // ==================== CART ROUTES ====================
  static const String cart = '$baseUrl/api/users/cart';
  static const String cartCount = '$baseUrl/api/users/cart/count';
  static const String addToCart = '$baseUrl/api/users/cart/add';
  static String cartItem(String itemId) =>
      '$baseUrl/api/users/cart/item/$itemId';
  static const String clearCart = '$baseUrl/api/users/cart/clear';

  // ==================== NOTIFICATION ROUTES ====================
  static const String notifications = '$baseUrl/api/users/notifications';
  static const String markAllRead = '$baseUrl/api/users/notifications/read-all';
  static String markNotificationRead(String notificationId) =>
      '$baseUrl/api/users/notifications/$notificationId/read';

  // ==================== PRODUCT ROUTES ====================
  static const String products = '$baseUrl/api/products';
  static const String productsOnSale = '$baseUrl/api/products/on-sale';
  static const String searchProducts = '$baseUrl/api/products/search';
  static String productDetail(String id) => '$baseUrl/api/products/$id';

  // ==================== CATEGORY ROUTES ====================
  static const String categories = '$baseUrl/api/categories';
  static String categoryDetail(String id) => '$baseUrl/api/categories/$id';
  static String categoryProducts(String id) =>
      '$baseUrl/api/categories/$id/products';

  // ==================== ORDER ROUTES ====================
  static const String createOrder = '$baseUrl/api/orders';
  static const String myOrders = '$baseUrl/api/orders/my-orders';
  static String myOrderDetail(String orderId) =>
      '$baseUrl/api/orders/my-orders/$orderId';
  static String cancelOrder(String orderId) =>
      '$baseUrl/api/orders/$orderId/cancel';

  // ==================== HTTP METHODS ====================
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';

  // ==================== HEADERS ====================
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
