// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://medicareplc.com/wp-json/wc/v3';
  static const String productsEndpoint = '$baseUrl/products';

  // IMPORTANT: Avoid hardcoding secrets in version control.
  // Use dart-define, .env files, or other secure methods.
  static const String consumerKey =
      'ck_b370bf2a312ee3fe0f8cb427228d304c4951c490';
  static const String consumerSecret =
      'cs_57af13d125fd533c0d7aaf95caff453d6cddab5c';
}
