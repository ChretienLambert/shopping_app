import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../services/isar_service.dart';
import '../services/logging_service.dart';

class ProductRepository {
  final _isar = IsarService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Product>> getAll() async {
    final db = await _isar.isar;
    return await db.products.filter().deletedAtIsNull().findAll();
  }

  Future<void> save(Product product) async {
    final db = await _isar.isar;
    product.isDirty = true;
    product.updatedAt = DateTime.now();
    
    await db.writeTxn(() async {
      await db.products.put(product);
    });

    await syncOne(product);
  }

  Future<void> syncOne(Product product) async {
    try {
      final db = await _isar.isar;
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
        'stock_quantity': product.stockQuantity,
        'image_path': product.imagePath,
        'deleted_at': product.deletedAt?.toIso8601String(),
        'updated_at': product.updatedAt.toIso8601String(),
      };

      await _supabase.from('products').upsert(data, onConflict: 'server_id');

      product.isDirty = false;
      product.lastSyncedAt = DateTime.now();
      
      await db.writeTxn(() async {
        await db.products.put(product);
      });
      logger.info('Synced product: ${product.name}');
    } catch (e) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation on Products', e);
      } else {
         logger.warning('Sync failed for product ${product.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Product product) async {
    final db = await _isar.isar;
    product.deletedAt = DateTime.now();
    product.updatedAt = DateTime.now();
    product.isDirty = true;
    
    await db.writeTxn(() async {
      await db.products.put(product);
    });
    
    await syncOne(product);
  }

  Future<void> syncDirty() async {
    final db = await _isar.isar;
    final dirtyRecords = await db.products.filter().isDirtyEqualTo(true).findAll();
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty products. Syncing...');
    for (var record in dirtyRecords) {
      await syncOne(record);
    }
  }

  Future<void> pullAll() async {
    try {
      final db = await _isar.isar;
      final response = await _supabase.from('products').select();
      
      final List<dynamic> remoteData = response;
      
      await db.writeTxn(() async {
        for (var data in remoteData) {
          final String sId = data['server_id']; // Use server_id from remote
          final existing = await db.products.filter().serverIdEqualTo(sId).findFirst();
          
          final product = existing ?? Product();
          product.serverId = sId;
          product.name = data['name'];
          product.description = data['description'];
          product.price = (data['price'] as num).toDouble();
          product.stockQuantity = data['stock_quantity'];
          product.imagePath = data['image_path'];
          product.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
          product.createdAt = DateTime.parse(data['created_at']);
          product.updatedAt = DateTime.parse(data['updated_at']);
          product.isDirty = false;
          product.lastSyncedAt = DateTime.now();
          
          await db.products.put(product);
        }
      });
      logger.info('Pulled all products from cloud');
    } catch (e) {
      logger.error('Pull all products failed', e);
    }
  }
}
