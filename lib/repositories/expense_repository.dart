import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';

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
    await syncOne(expense);
  }

  Future<void> syncOne(Expense expense) async {
    try {
      final box = _hive.expensesBox;
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      final baseData = {
        'server_id': expense.serverId,
        'user_id': currentUser.id,
        'description': expense.description,
        'amount': expense.amount,
        'category': expense.category.name,
        'expense_date': expense.expenseDate.toIso8601String(),
        'notes': expense.notes,
        'receipt_image_path': expense.receiptImagePath,
        'deleted_at': expense.deletedAt?.toIso8601String(),
        'updated_at': expense.updatedAt.toIso8601String(),
      };

      final extendedData = {
        ...baseData,
        'stock_product_name': expense.stockProductName,
        'stock_product_type': expense.stockProductType,
        'stock_quality': expense.stockQuality,
        'stock_quantity': expense.stockQuantity,
        'stock_purchase_price': expense.stockPurchasePrice,
        'stock_resale_price': expense.stockResalePrice,
        'stock_image_path': expense.stockImagePath,
      };

      try {
        await _supabase.from('expenses').upsert(extendedData, onConflict: 'server_id');
      } catch (e) {
        if (e.toString().contains('PGRST204')) {
          logger.warning('Expenses table missing new stock columns, syncing legacy payload.');
          await _supabase.from('expenses').upsert(baseData, onConflict: 'server_id');
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
    await syncOne(expense);
  }

  Future<void> syncDirty() async {
    final box = _hive.expensesBox;
    final dirtyRecords = box.values
        .map((e) => Expense.fromJson(e))
        .where((e) => e.isDirty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty expenses. Syncing...');
    for (var expense in dirtyRecords) {
      await syncOne(expense);
    }
  }

  Future<void> pullAll() async {
    try {
      final box = _hive.expensesBox;
      final response = await _supabase.from('expenses').select();
      
      final List<dynamic> remoteData = response;
      
      for (var data in remoteData) {
        final String sId = data['server_id'];
        
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
      default:
        return ExpenseCategory.business;
    }
  }
}
