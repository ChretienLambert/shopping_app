import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../repositories/customer_repository.dart';
import '../repositories/product_repository.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';
import '../services/sync_record_resolver.dart';

class SaleRepository {
  final _hive = HiveService.instance;
  final _supabase = Supabase.instance.client;
  final _customerRepository = CustomerRepository();
  final _productRepository = ProductRepository();

  Future<List<Sale>> getAll() async {
    final box = _hive.salesBox;
    return box.values
        .map((s) => Sale.fromJson(s))
        .where((s) => s.deletedAt == null)
        .toList();
  }

  Future<void> save(Sale sale, List<SaleItem> items) async {
    final salesBox = _hive.salesBox;
    final itemsBox = _hive.getBox('sale_items');
    
    sale.isDirty = true;
    sale.updatedAt = DateTime.now();
    
    await salesBox.put(sale.id, sale.toJson());
    
    for (var item in items) {
      item.saleId = sale.id;
      await itemsBox.put(item.id, item.toJson());
    }

    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(sale, items);
    // }
  }

  Future<void> syncOne(Sale sale, List<SaleItem> items) async {
    try {
      final salesBox = _hive.salesBox;
      final customersBox = _hive.customersBox;
      final productsBox = _hive.productsBox;
      
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      await _ensureDependenciesSynced(sale, items);
      
      // Get server ID for customer
      final customerMap = customersBox.get(sale.customerId);
      String? customerServerId;
      if (customerMap != null) {
        customerServerId = Customer.fromJson(customerMap).serverId;
      }

      final data = {
        'id': sale.id,
        'server_id': sale.serverId ?? sale.id,
        'user_id': currentUser.id,
        'customer_id': customerServerId,
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

      final response = await _supabase
          .from('sales')
          .upsert(data, onConflict: 'server_id')
          .select()
          .single();
      sale.serverId = response['server_id'];

      // Sync items
      for (var item in items) {
        final productMap = productsBox.get(item.productId);
        if (productMap != null) {
          final product = Product.fromJson(productMap);
          if (product.serverId == null) {
            logger.warning(
              'Skipping sale item sync for ${item.id} because product ${product.id} has no serverId after dependency sync.',
            );
            continue;
          }
          final itemData = {
            'id': item.id,
            'server_id': item.serverId ?? item.id,
            'sale_id': sale.serverId,
            'product_id': product.serverId,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'total_price': item.totalPrice,
          };
          final itemResponse = await _supabase
              .from('sale_items')
              .upsert(itemData, onConflict: 'server_id')
              .select()
              .single();
          item.serverId = itemResponse['server_id'];
          // Update local item with its serverId
          final itemsBox = _hive.getBox('sale_items');
          await itemsBox.put(item.id, item.toJson());
        }
      }

      sale.isDirty = false;
      sale.lastSyncedAt = DateTime.now();
      
      await salesBox.put(sale.id, sale.toJson());
      logger.info('Synced sale: ${sale.serverId}');
    } catch (e, stack) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation on Sales', e, stack);
      } else {
         logger.warning('Sync failed for sale ${sale.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Sale sale) async {
    if (sale.isLocked) {
      throw Exception('Paid and completed/delivered sales cannot be deleted.');
    }

    final box = _hive.salesBox;
    sale.deletedAt = DateTime.now();
    sale.updatedAt = DateTime.now();
    sale.isDirty = true;
    
    await box.put(sale.id, sale.toJson());
    
    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(sale, []);
    // }
  }

  Future<void> syncDirty() async {
    final box = _hive.salesBox;
    final dirtyRecords = box.values
        .whereType<Map>()
        .map((s) => Sale.fromJson(s))
        .where((s) => s.isDirty && s.id.isNotEmpty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty sales. Syncing...');
    for (var sale in dirtyRecords) {
      final items = await getSaleItems(sale.id);
      await syncOne(sale, items);
    }
  }

  Future<void> pullAll({DateTime? lastSync}) async {
    try {
      final salesBox = _hive.salesBox;
      final customersBox = _hive.customersBox;
      final productsBox = _hive.productsBox;
      final itemsBox = _hive.getBox('sale_items');

      var query = _supabase.from('sales').select();
      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }

      final response = await query;
      final List<dynamic> remoteData = response;
      logger.info('Fetched ${remoteData.length} sales from Supabase');
      
      for (var data in remoteData) {
        final String sId = data['server_id'];

        final existingJson = SyncRecordResolver.findExistingRecord(
          salesBox.values,
          localId: sId,
          serverId: sId,
        );

        if (existingJson != null) {
          final existing = Sale.fromJson(existingJson);
          final remoteUpdatedAt = DateTime.parse(data['updated_at']);
          if (!remoteUpdatedAt.isAfter(existing.updatedAt)) {
            continue;
          }
        }

        final sale = existingJson != null
            ? Sale.fromJson(existingJson)
            : Sale(id: SyncRecordResolver.stableLocalId(existingJson: existingJson, remoteServerId: sId));
        sale.serverId = sId;
        
        // Map customer_id back to local ID
        if (data['customer_id'] != null) {
          final String cServerId = data['customer_id'];
          final localCustomer = customersBox.values
              .map((c) => Customer.fromJson(c))
              .firstWhere((c) => c.serverId == cServerId, orElse: () => Customer(id: '0'));
          sale.customerId = localCustomer.id;
        } else {
          sale.customerId = '0';
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
        
        await salesBox.put(sale.id, sale.toJson());
        
        // Pull and update items
        final itemsResponse = await _supabase.from('sale_items').select().eq('sale_id', sId);
        
        // Clear local items for this sale first
        final itemsToRemove = itemsBox.values
            .map((i) => SaleItem.fromJson(i))
            .where((i) => i.saleId == sale.id)
            .map((i) => i.id)
            .toList();
        for (var id in itemsToRemove) {
          await itemsBox.delete(id);
        }
        
        for (var itemData in itemsResponse) {
           final String? pServerId = itemData['product_id'];
           if (pServerId == null) continue;

           final localProduct = productsBox.values
               .map((p) => Product.fromJson(p))
               .firstWhere((p) => p.serverId == pServerId, orElse: () => Product(id: '0'));
               
           if (localProduct.id != '0') {
             final item = SaleItem(id: itemData['server_id'] ?? itemData['id']);
             item.serverId = itemData['server_id'] ?? item.serverId;
             item.saleId = sale.id;
             item.productId = localProduct.id;
             item.quantity = itemData['quantity'];
             item.unitPrice = (itemData['unit_price'] as num).toDouble();
             item.totalPrice = (itemData['total_price'] as num).toDouble();
             await itemsBox.put(item.id, item.toJson());
           }
        }
      }
      logger.info('Pulled all sales and items from cloud');
    } catch (e, stack) {
      logger.error('Pull all sales failed', e, stack);
    }
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final itemsBox = _hive.getBox('sale_items');
    return itemsBox.values
        .map((i) => SaleItem.fromJson(i as Map))
        .where((i) => i.saleId == saleId)
        .toList();
  }

  Future<void> _ensureDependenciesSynced(Sale sale, List<SaleItem> items) async {
    final customerMap = _hive.customersBox.get(sale.customerId);
    if (customerMap != null) {
      final customer = Customer.fromJson(customerMap);
      if (customer.serverId == null || customer.isDirty) {
        await _customerRepository.syncOne(customer);
      }
    }

    for (final item in items) {
      final productMap = _hive.productsBox.get(item.productId);
      if (productMap == null) continue;
      final product = Product.fromJson(productMap);
      if (product.serverId == null || product.isDirty) {
        await _productRepository.syncOne(product);
      }
    }
  }
}
