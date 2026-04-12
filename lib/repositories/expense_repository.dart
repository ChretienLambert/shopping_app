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

      final data = {
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

      await _supabase.from('expenses').upsert(data, onConflict: 'server_id');

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
          expense.category = ExpenseCategory.values.firstWhere(
            (e) => e.name == data['category'],
            orElse: () => ExpenseCategory.other,
          );
          expense.expenseDate = DateTime.parse(data['expense_date']);
          expense.notes = data['notes'];
          expense.receiptImagePath = data['receipt_image_path'];
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
}
