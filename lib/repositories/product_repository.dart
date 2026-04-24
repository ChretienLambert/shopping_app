import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';
import '../services/storage_service.dart';
import '../services/sync_record_resolver.dart';

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

    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(product);
    // }
  }

  Future<void> syncOne(Product product) async {
    try {
      final box = _hive.productsBox;
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      // Handle image uploads
      String? remotePath = product.imagePath;
      if (product.imagePath != null && !product.imagePath!.startsWith('http')) {
        remotePath = await storageService.uploadToSupabase(product.imagePath!, 'products');
        if (remotePath != null) {
          product.imagePath = remotePath;
        }
      }

      final data = {
        'id': product.id,
        'server_id': product.serverId ?? product.id,
        'user_id': currentUser.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'purchase_price': product.purchasePrice,
        'stock_quantity': product.stockQuantity,
        'image_path': remotePath,
        'product_type': product.productType,
        'quality': product.quality,
        'deleted_at': product.deletedAt?.toIso8601String(),
        'updated_at': product.updatedAt.toIso8601String(),
      };

      final response = await _supabase
          .from('products')
          .upsert(data, onConflict: 'server_id')
          .select()
          .single();

      product.serverId = response['server_id'];
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

    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(product);
    // }
  }

  Future<void> syncDirty() async {
    final box = _hive.productsBox;
    final dirtyRecords = box.values
        .whereType<Map>()
        .map((p) => Product.fromJson(p))
        .where((p) => p.isDirty && p.id.isNotEmpty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty products. Syncing...');
    for (var product in dirtyRecords) {
      await syncOne(product);
    }
  }

  Future<void> pullAll({DateTime? lastSync}) async {
    try {
      final box = _hive.productsBox;
      var query = _supabase.from('products').select();
      
      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }
      
      final response = await query;
      final List<dynamic> remoteData = response;
      logger.info('Fetched ${remoteData.length} products from Supabase');
      
      for (var data in remoteData) {
        final String? sId = data['server_id'];
        if (sId == null) continue;

        final existingJson = SyncRecordResolver.findExistingRecord(
          box.values,
          localId: sId,
          serverId: sId,
        );

        if (existingJson != null) {
          final existing = Product.fromJson(existingJson);
          final remoteUpdatedAt = DateTime.parse(data['updated_at']);

          if (!remoteUpdatedAt.isAfter(existing.updatedAt)) {
            continue;
          }
        }

        final product = existingJson != null
            ? Product.fromJson(existingJson)
            : Product(id: SyncRecordResolver.stableLocalId(existingJson: existingJson, remoteServerId: sId));
        product.serverId = sId;
        product.name = data['name'];
        product.description = data['description'];
        product.price = (data['price'] as num).toDouble();
        product.purchasePrice = ((data['purchase_price'] ?? 0) as num).toDouble();
        product.stockQuantity = data['stock_quantity'];
        product.imagePath = data['image_path'];
        product.productType = data['product_type'];
        product.quality = data['quality'];
        product.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
        product.createdAt = DateTime.parse(data['created_at']);
        product.updatedAt = DateTime.parse(data['updated_at']);
        product.isDirty = false;
        product.lastSyncedAt = DateTime.now();
        
        await box.put(product.id, product.toJson());
      }
      logger.info('Pulled all products from cloud');
    } catch (e, stack) {
      logger.error('Pull all products failed', e, stack);
    }
  }
}
