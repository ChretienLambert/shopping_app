import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';

class ProductRepository {
  final _hive = HiveService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Product>> getAll() async {
    final box = _hive.productsBox;
    return box.values
        .map((p) => Product.fromJson(p))
        .where((p) => p.deletedAt == null)
        .toList();
  }

  Future<void> save(Product product) async {
    final box = _hive.productsBox;
    product.isDirty = true;
    product.updatedAt = DateTime.now();
    
    await box.put(product.id, product.toJson());
    await syncOne(product);
  }

  Future<void> syncOne(Product product) async {
    try {
      final box = _hive.productsBox;
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      final data = {
        'server_id': product.serverId,
        'user_id': currentUser.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'purchase_price': product.purchasePrice,
        'stock_quantity': product.stockQuantity,
        'image_path': product.imagePath,
        'product_type': product.productType,
        'quality': product.quality,
        'deleted_at': product.deletedAt?.toIso8601String(),
        'updated_at': product.updatedAt.toIso8601String(),
      };

      await _supabase.from('products').upsert(data, onConflict: 'server_id');

      product.isDirty = false;
      product.lastSyncedAt = DateTime.now();
      
      await box.put(product.id, product.toJson());
      logger.info('Synced product: ${product.name}');
    } catch (e, stack) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation on Products', e, stack);
      } else {
         logger.warning('Sync failed for product ${product.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Product product) async {
    final box = _hive.productsBox;
    product.deletedAt = DateTime.now();
    product.updatedAt = DateTime.now();
    product.isDirty = true;
    
    await box.put(product.id, product.toJson());
    await syncOne(product);
  }

  Future<void> syncDirty() async {
    final box = _hive.productsBox;
    final dirtyRecords = box.values
        .map((p) => Product.fromJson(p))
        .where((p) => p.isDirty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty products. Syncing...');
    for (var product in dirtyRecords) {
      await syncOne(product);
    }
  }

  Future<void> pullAll() async {
    try {
      final box = _hive.productsBox;
      final response = await _supabase.from('products').select();
      
      final List<dynamic> remoteData = response;
      
      for (var data in remoteData) {
        final String sId = data['server_id'];
        
        // Find existing local product by serverId
        final existing = box.values
            .map((p) => Product.fromJson(p))
            .firstWhere((p) => p.serverId == sId, orElse: () => Product());

        existing.serverId = sId;
        existing.name = data['name'];
        existing.description = data['description'];
        existing.price = (data['price'] as num).toDouble();
        existing.purchasePrice = ((data['purchase_price'] ?? 0) as num).toDouble();
        existing.stockQuantity = data['stock_quantity'];
        existing.imagePath = data['image_path'];
        existing.productType = data['product_type'];
        existing.quality = data['quality'];
        existing.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
        existing.createdAt = DateTime.parse(data['created_at']);
        existing.updatedAt = DateTime.parse(data['updated_at']);
        existing.isDirty = false;
        existing.lastSyncedAt = DateTime.now();
        
        await box.put(existing.id, existing.toJson());
      }
      logger.info('Pulled all products from cloud');
    } catch (e, stack) {
      logger.error('Pull all products failed', e, stack);
    }
  }
}
