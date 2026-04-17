import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';
import '../services/storage_service.dart';

class ExpenseRepository {
  final _hive = HiveService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Expense>> getAll() async {
    final box = _hive.expensesBox;
    return box.values
        .map((e) => Expense.fromJson(e))
        .where((e) => e.deletedAt == null)
        .toList();
  }

  Future<void> save(Expense expense) async {
    final box = _hive.expensesBox;
    expense.isDirty = true;
    expense.updatedAt = DateTime.now();
    
    await box.put(expense.id, expense.toJson());
    
    if (expense.category == ExpenseCategory.stock && expense.deletedAt == null) {
      await _processStockItem(expense);
    }

    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(expense);
    // }
  }

  Future<void> _processStockItem(Expense item) async {
    try {
      final pRepo = HiveService.instance.getBox('products');
      // Look for existing product by type (category) and name
      // Normalize comparison
      final itemName = item.stockProductName?.trim().toLowerCase();
      final itemType = item.stockProductType?.trim().toLowerCase();

      final existingEntry = pRepo.values.cast<Map<dynamic, dynamic>>().where(
        (p) {
          final pName = (p['name'] as String?)?.trim().toLowerCase();
          final pType = (p['productType'] as String?)?.trim().toLowerCase();
          return pName == itemName && pType == itemType;
        },
      ).firstOrNull;

      if (existingEntry != null) {
        // Update stock
        final p = Map<String, dynamic>.from(existingEntry);
        p['stockQuantity'] = (p['stockQuantity'] ?? 0) + (item.stockQuantity ?? 0);
        
        p['updatedAt'] = DateTime.now().toIso8601String();
        p['isDirty'] = true;
        await pRepo.put(p['id'], p);
        logger.info('Updated existing product stock: ${item.stockProductName}');
      } else {
        // Create new product (Using raw UUID for Supabase compatibility)
        final newId = const Uuid().v4();
        final newProduct = {
          'id': newId,
          'name': item.stockProductName ?? 'New Stock',
          'productType': item.stockProductType,
          'quality': item.stockQuality,
          'description': item.notes ?? '',
          'stockQuantity': item.stockQuantity ?? 0,
          'purchasePrice': item.stockPurchasePrice ?? 0.0,
          'price': item.stockResalePrice ?? 0.0,
          'imagePath': item.stockImagePath,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'isDirty': true,
        };
        await pRepo.put(newId, newProduct);
        logger.info('Created new product from stock: ${item.stockProductName}');
      }
    } catch (e) {
      logger.warning('Failed to process stock item: $e');
    }
  }

  Future<void> syncOne(Expense expense) async {
    try {
      final box = _hive.expensesBox;
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      // Handle image uploads before syncing data
      String? remoteReceiptPath = expense.receiptImagePath;
      if (expense.receiptImagePath != null && !expense.receiptImagePath!.startsWith('http')) {
        remoteReceiptPath = await storageService.uploadToSupabase(expense.receiptImagePath!, 'receipts');
        if (remoteReceiptPath != null) {
          expense.receiptImagePath = remoteReceiptPath;
        }
      }

      String? remoteStockPath = expense.stockImagePath;
      if (expense.stockImagePath != null && !expense.stockImagePath!.startsWith('http')) {
        remoteStockPath = await storageService.uploadToSupabase(expense.stockImagePath!, 'products');
        if (remoteStockPath != null) {
          expense.stockImagePath = remoteStockPath;
        }
      }

      final data = {
        'id': expense.id,
        'server_id': expense.serverId ?? expense.id,
        'user_id': currentUser.id,
        'description': expense.description,
        'amount': expense.amount,
        'category': expense.category.name,
        'expense_date': expense.expenseDate.toIso8601String(),
        'notes': expense.notes,
        'receipt_image_path': remoteReceiptPath,
        'stock_product_name': expense.stockProductName,
        'stock_product_type': expense.stockProductType,
        'stock_quality': expense.stockQuality,
        'stock_quantity': expense.stockQuantity,
        'stock_purchase_price': expense.stockPurchasePrice,
        'stock_resale_price': expense.stockResalePrice,
        'stock_image_path': remoteStockPath,
        'deleted_at': expense.deletedAt?.toIso8601String(),
        'updated_at': expense.updatedAt.toIso8601String(),
        'operation_id': expense.operationId,
      };

      try {
        final response = await _supabase
            .from('expenses')
            .upsert(data, onConflict: 'server_id')
            .select()
            .single();
        expense.serverId = response['server_id'];
      } catch (e) {
        if (e.toString().contains('PGRST204')) {
          logger.warning('Expenses table missing new stock columns, syncing legacy payload.');
          final baseData = {
            'id': expense.id,
            'server_id': expense.serverId ?? expense.id,
            'user_id': currentUser.id,
            'description': expense.description,
            'amount': expense.amount,
            'category': expense.category.name,
            'expense_date': expense.expenseDate.toIso8601String(),
            'notes': expense.notes,
            'receipt_image_path': remoteReceiptPath,
            'deleted_at': expense.deletedAt?.toIso8601String(),
            'updated_at': expense.updatedAt.toIso8601String(),
            'operation_id': expense.operationId,
          };
          final response = await _supabase
              .from('expenses')
              .upsert(baseData, onConflict: 'server_id')
              .select()
              .single();
          expense.serverId = response['server_id'];
        } else {
          rethrow;
        }
      }

      expense.isDirty = false;
      expense.lastSyncedAt = DateTime.now();
      
      await box.put(expense.id, expense.toJson());
      logger.info('Synced expense: ${expense.description}');
    } catch (e, stack) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation on Expenses', e, stack);
      } else {
         logger.warning('Sync failed for expense ${expense.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Expense expense) async {
    final box = _hive.expensesBox;
    expense.deletedAt = DateTime.now();
    expense.updatedAt = DateTime.now();
    expense.isDirty = true;
    
    await box.put(expense.id, expense.toJson());

    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(expense);
    // }
  }

  Future<void> syncDirty() async {
    final box = _hive.expensesBox;
    final dirtyRecords = box.values
        .whereType<Map>()
        .map((e) => Expense.fromJson(e))
        .where((e) => e.isDirty && e.id.isNotEmpty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty expenses. Syncing...');
    for (var expense in dirtyRecords) {
      await syncOne(expense);
    }
  }

  Future<void> pullAll({DateTime? lastSync}) async {
    try {
      final box = _hive.expensesBox;
      var query = _supabase.from('expenses').select();
      
      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }

      final response = await query;
      
      final List<dynamic> remoteData = response;
      
      for (var data in remoteData) {
        final String? sId = data['server_id'];
        if (sId == null) continue;

        final existing = box.values
            .map((e) => Expense.fromJson(e))
            .firstWhere((e) => e.serverId == sId, orElse: () => Expense());

        existing.serverId = sId;
        existing.description = data['description'];
        existing.amount = (data['amount'] as num).toDouble();
        final rawCategory = (data['category'] as String?) ?? '';
        existing.category = _mapRemoteCategory(rawCategory);
        existing.expenseDate = DateTime.parse(data['expense_date']);
        existing.notes = data['notes'];
        existing.receiptImagePath = data['receipt_image_path'];
        existing.stockProductName = data['stock_product_name'];
        existing.stockProductType = data['stock_product_type'];
        existing.stockQuality = data['stock_quality'];
        existing.stockQuantity = data['stock_quantity'];
        existing.stockPurchasePrice =
            data['stock_purchase_price'] != null
                ? (data['stock_purchase_price'] as num).toDouble()
                : null;
        existing.stockResalePrice =
            data['stock_resale_price'] != null
                ? (data['stock_resale_price'] as num).toDouble()
                : null;
        existing.stockImagePath = data['stock_image_path'];
        existing.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
        existing.createdAt = DateTime.parse(data['created_at']);
        existing.updatedAt = DateTime.parse(data['updated_at']);
        existing.isDirty = false;
        existing.lastSyncedAt = DateTime.now();

        await box.put(existing.id, existing.toJson());
      }
      logger.info('Pulled all expenses from cloud');
    } catch (e, stack) {
      logger.error('Pull all expenses failed', e, stack);
    }
  }

  ExpenseCategory _mapRemoteCategory(String remoteCategory) {
    switch (remoteCategory) {
      case 'stock':
        return ExpenseCategory.stock;
      case 'business':
        return ExpenseCategory.business;
      case 'personalPayout':
      case 'personal_payout':
        return ExpenseCategory.personalPayout;
      case 'capitalInjection':
      case 'capital_injection':
        return ExpenseCategory.capitalInjection;
      default:
        return ExpenseCategory.business;
    }
  }
}
