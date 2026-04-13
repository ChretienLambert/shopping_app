import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';
import '../services/isar_service.dart';
import '../services/logging_service.dart';

class ExpenseRepository {
  final _isar = IsarService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Expense>> getAll() async {
    final db = await _isar.isar;
    return await db.expenses.filter().deletedAtIsNull().findAll();
  }

  Future<void> save(Expense expense) async {
    final db = await _isar.isar;
    expense.isDirty = true;
    expense.updatedAt = DateTime.now();
    
    await db.writeTxn(() async {
      await db.expenses.put(expense);
    });

    await syncOne(expense);
  }

  Future<void> syncOne(Expense expense) async {
    try {
      final db = await _isar.isar;
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
        // Backward compatibility if remote schema has not been updated yet.
        if (e.toString().contains('PGRST204')) {
          logger.warning('Expenses table missing new stock columns, syncing legacy payload.');
          await _supabase.from('expenses').upsert(baseData, onConflict: 'server_id');
        } else {
          rethrow;
        }
      }

      expense.isDirty = false;
      expense.lastSyncedAt = DateTime.now();
      
      await db.writeTxn(() async {
        await db.expenses.put(expense);
      });
      logger.info('Synced expense: ${expense.description}');
    } catch (e) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation on Expenses', e);
      } else {
         logger.warning('Sync failed for expense ${expense.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Expense expense) async {
    final db = await _isar.isar;
    expense.deletedAt = DateTime.now();
    expense.updatedAt = DateTime.now();
    expense.isDirty = true;
    
    await db.writeTxn(() async {
      await db.expenses.put(expense);
    });
    
    await syncOne(expense);
  }

  Future<void> syncDirty() async {
    final db = await _isar.isar;
    final dirtyRecords = await db.expenses.filter().isDirtyEqualTo(true).findAll();
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty expenses. Syncing...');
    for (var record in dirtyRecords) {
      await syncOne(record);
    }
  }

  Future<void> pullAll() async {
    try {
      final db = await _isar.isar;
      final response = await _supabase.from('expenses').select();
      
      final List<dynamic> remoteData = response;
      
      await db.writeTxn(() async {
        for (var data in remoteData) {
          final String sId = data['server_id']; // Use server_id from remote
          final existing = await db.expenses.filter().serverIdEqualTo(sId).findFirst();
          
          final expense = existing ?? Expense();
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
          
          await db.expenses.put(expense);
        }
      });
      logger.info('Pulled all expenses from cloud');
    } catch (e) {
      logger.error('Pull all expenses failed', e);
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
      // Backward compatibility for existing server rows.
      case 'socialMedia':
      case 'stand':
      case 'transportation':
      case 'supplies':
      case 'utilities':
      case 'rent':
      case 'marketing':
      case 'other':
      default:
        return ExpenseCategory.business;
    }
  }
}
