import 'package:medicare_app/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int page = 1, int limit = 20});
  Future<List<ProductEntity>> searchProducts(String query);
}
