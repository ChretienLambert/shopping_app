import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';
import '../services/storage_service.dart';
import '../services/sync_record_resolver.dart';

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
    final Map? existingData = box.get(expense.id);
    Expense? previousVersion;
    if (existingData != null) {
      previousVersion = Expense.fromJson(existingData);
    }
    
    expense.isDirty = true;
    expense.updatedAt = DateTime.now();
    
    await box.put(expense.id, expense.toJson());
    
    if (expense.category == ExpenseCategory.stock && expense.deletedAt == null) {
      await _processStockUpdate(expense, previousVersion);
    }
  }

  Future<void> _processStockUpdate(Expense current, Expense? previous) async {
    try {
      final pRepo = HiveService.instance.getBox('products');
      
      // If previous version exists and name/type changed, we might have a problem.
      // But typically user edits same product.
      
      final itemName = current.stockProductName?.trim().toLowerCase();
      final itemType = current.stockProductType?.trim().toLowerCase();

      final existingEntry = pRepo.values.cast<Map<dynamic, dynamic>>().where(
        (p) {
          final pName = (p['name'] as String?)?.trim().toLowerCase();
          final pType = (p['productType'] as String?)?.trim().toLowerCase();
          return pName == itemName && pType == itemType;
        },
      ).firstOrNull;

      if (existingEntry != null) {
        final p = Map<String, dynamic>.from(existingEntry);
        
        int currentQty = current.stockQuantity ?? 0;
        int previousQty = previous?.stockQuantity ?? 0;
        int delta = currentQty - previousQty;

        if (delta != 0 || current.stockImagePath != previous?.stockImagePath || current.stockResalePrice != previous?.stockResalePrice) {
          p['stockQuantity'] = (p['stockQuantity'] ?? 0) + delta;
          p['imagePath'] = current.stockImagePath;
          p['price'] = current.stockResalePrice ?? p['price'];
          p['updatedAt'] = DateTime.now().toIso8601String();
          p['isDirty'] = true;
          await pRepo.put(p['id'], p);
          logger.info('Updated product stock delta: $delta for ${current.stockProductName}');
        }
      } else if (previous == null) {
        // Only create new if it's actually a new expense
        final newId = const Uuid().v4();
        final newProduct = {
          'id': newId,
          'name': current.stockProductName ?? 'New Stock',
          'productType': current.stockProductType,
          'quality': current.stockQuality,
          'description': current.notes ?? '',
          'stockQuantity': current.stockQuantity ?? 0,
          'purchasePrice': current.stockPurchasePrice ?? 0.0,
          'price': current.stockResalePrice ?? 0.0,
          'imagePath': current.stockImagePath,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'isDirty': true,
        };
        await pRepo.put(newId, newProduct);
        logger.info('Created new product from stock: ${current.stockProductName}');
      }
    } catch (e) {
      logger.warning('Failed to process stock update: $e');
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
      logger.info('Fetched ${remoteData.length} expenses from Supabase');
      
      for (var data in remoteData) {
        final String? sId = data['server_id'];
        if (sId == null) continue;

        final existingJson = SyncRecordResolver.findExistingRecord(
          box.values,
          localId: sId,
          serverId: sId,
        );

        if (existingJson != null) {
          final existing = Expense.fromJson(existingJson);
          final remoteUpdatedAt = DateTime.parse(data['updated_at']);
          if (!remoteUpdatedAt.isAfter(existing.updatedAt)) {
            continue;
          }
        }

        final expense = existingJson != null
            ? Expense.fromJson(existingJson)
            : Expense(id: SyncRecordResolver.stableLocalId(existingJson: existingJson, remoteServerId: sId));
        expense.serverId = sId;
        expense.description = data['description'];
        expense.amount = (data['amount'] as num).toDouble();
        final rawCategory = (data['category'] as String?) ?? '';
        expense.category = _mapRemoteCategory(rawCategory);
        expense.expenseDate = DateTime.parse(data['expense_date']);
        expense.notes = data['notes'];
        expense.receiptImagePath = data['receipt_image_path'];
        expense.stockProductName = data['stock_product_name'];
        expense.stockProductType = data['stock_product_type'];
        expense.stockQuality = data['stock_quality'];
        expense.stockQuantity = data['stock_quantity'];
        expense.stockPurchasePrice =
            data['stock_purchase_price'] != null
                ? (data['stock_purchase_price'] as num).toDouble()
                : null;
        expense.stockResalePrice =
            data['stock_resale_price'] != null
                ? (data['stock_resale_price'] as num).toDouble()
                : null;
        expense.stockImagePath = data['stock_image_path'];
        expense.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
        expense.createdAt = DateTime.parse(data['created_at']);
        expense.updatedAt = DateTime.parse(data['updated_at']);
        expense.isDirty = false;
        expense.lastSyncedAt = DateTime.now();

        await box.put(expense.id, expense.toJson());
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
