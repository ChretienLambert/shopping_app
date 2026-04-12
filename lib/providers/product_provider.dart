import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductNotifier extends StateNotifier<List<Product>> {
  final _repository = ProductRepository();

  ProductNotifier() : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    final products = await _repository.getAll();
    state = products;
  }

  Future<void> addProduct(Product product) async {
    await _repository.save(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.save(product);
    await loadProducts();
  }

  Future<void> deleteProduct(Product product) async {
    await _repository.softDelete(product);
    await loadProducts();
  }

  Future<Product?> getProductById(int id) async {
    final products = await _repository.getAll();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});
