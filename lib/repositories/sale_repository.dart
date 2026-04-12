import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../services/isar_service.dart';
import '../services/logging_service.dart';

class SaleRepository {
  final _isar = IsarService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Sale>> getAll() async {
    final db = await _isar.isar;
    return await db.sales.filter().deletedAtIsNull().findAll();
  }

  Future<void> save(Sale sale, List<SaleItem> items) async {
    final db = await _isar.isar;
    sale.isDirty = true;
    sale.updatedAt = DateTime.now();
    
    await db.writeTxn(() async {
      await db.sales.put(sale);
      for (var item in items) {
        item.saleId = sale.id;
        await db.saleItems.put(item);
      }
    });

    await syncOne(sale, items);
  }

  Future<void> syncOne(Sale sale, List<SaleItem> items) async {
    try {
      final db = await _isar.isar;
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }
      
      // Get server IDs for relations
      final customer = await db.customers.get(sale.customerId);
      String? customerServerId = customer?.serverId;

      final data = {
        'server_id': sale.serverId,
        'customer_id': customerServerId,
        'user_id': currentUser.id,
        'total_amount': sale.totalAmount,
        'sale_date': sale.saleDate.toIso8601String(),
        'notes': sale.notes,
        'metadata_json': sale.metadataJson,
        'status': sale.status,
        'is_paid': sale.isPaid,
        'is_delivery': sale.isDelivery,
        'delivery_address': sale.deliveryAddress,
        'deleted_at': sale.deletedAt?.toIso8601String(),
        'updated_at': sale.updatedAt.toIso8601String(),
      };

      await _supabase.from('sales').upsert(data, onConflict: 'server_id');

      // Sync items
      for (var item in items) {
        final product = await db.products.get(item.productId);
        if (product?.serverId != null) {
          final itemData = {
            'server_id': item.serverId,
            'sale_id': sale.serverId,
            'product_id': product!.serverId,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'total_price': item.totalPrice,
          };
          await _supabase.from('sale_items').upsert(itemData, onConflict: 'server_id');
        }
      }

      sale.isDirty = false;
      sale.lastSyncedAt = DateTime.now();
      
      await db.writeTxn(() async {
        await db.sales.put(sale);
      });
      logger.info('Synced sale: ${sale.serverId}');
    } catch (e) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation on Sales', e);
      } else {
         logger.warning('Sync failed for sale ${sale.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Sale sale) async {
    if (sale.isLocked) {
      throw Exception('Paid and completed/delivered sales cannot be deleted.');
    }

    final db = await _isar.isar;
    sale.deletedAt = DateTime.now();
    sale.updatedAt = DateTime.now();
    sale.isDirty = true;
    
    await db.writeTxn(() async {
      await db.sales.put(sale);
    });
    
    final items = await getSaleItems(sale.id);
    await syncOne(sale, items);
  }

  Future<void> syncDirty() async {
    final db = await _isar.isar;
    final dirtyRecords = await db.sales.filter().isDirtyEqualTo(true).findAll();
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty sales. Syncing...');
    for (var record in dirtyRecords) {
      final items = await getSaleItems(record.id);
      await syncOne(record, items);
    }
  }

  Future<void> pullAll() async {
    try {
      final db = await _isar.isar;
      final response = await _supabase.from('sales').select();
      
      final List<dynamic> remoteData = response;
      
      await db.writeTxn(() async {
        for (var data in remoteData) {
          final String sId = data['server_id']; // Use server_id from remote
          final existing = await db.sales.filter().serverIdEqualTo(sId).findFirst();
          
          final sale = existing ?? Sale();
          sale.serverId = sId;
          
          // Map customer_id back to local ID
          if (data['customer_id'] != null) {
            final customer = await db.customers.filter().serverIdEqualTo(data['customer_id']).findFirst();
            sale.customerId = customer?.id ?? 0;
          } else {
            sale.customerId = 0;
          }
          
          sale.totalAmount = (data['total_amount'] as num).toDouble();
          sale.saleDate = DateTime.parse(data['sale_date']);
          sale.notes = data['notes'];
          sale.metadataJson = data['metadata_json'];
          sale.status = data['status'] ?? 'Complete';
          sale.isPaid = data['is_paid'] ?? true;
          sale.isDelivery = data['is_delivery'] ?? false;
          sale.deliveryAddress = data['delivery_address'];
          sale.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
          sale.createdAt = DateTime.parse(data['created_at']);
          sale.updatedAt = DateTime.parse(data['updated_at']);
          sale.isDirty = false;
          sale.lastSyncedAt = DateTime.now();
          
          await db.sales.put(sale);
          
          // Pull items for this sale
          final itemsResponse = await _supabase.from('sale_items').select().eq('sale_id', sId);
          await db.saleItems.filter().saleIdEqualTo(sale.id).deleteAll(); // Replace local items
          
          for (var itemData in itemsResponse) {
             final product = await db.products.filter().serverIdEqualTo(itemData['product_id']).findFirst();
             if (product != null) {
               final item = SaleItem();
               item.serverId = itemData['server_id'] ?? item.serverId;
               item.saleId = sale.id;
               item.productId = product.id;
               item.quantity = itemData['quantity'];
               item.unitPrice = (itemData['unit_price'] as num).toDouble();
               item.totalPrice = (itemData['total_price'] as num).toDouble();
               await db.saleItems.put(item);
             }
          }
        }
      });
      logger.info('Pulled all sales and items from cloud');
    } catch (e) {
      logger.error('Pull all sales failed', e);
    }
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await _isar.isar;
    return await db.saleItems.filter().saleIdEqualTo(saleId).findAll();
  }
}
