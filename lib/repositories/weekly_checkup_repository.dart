import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weekly_checkup.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';
import '../services/sync_record_resolver.dart';

class WeeklyCheckupRepository {
  final _hive = HiveService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<WeeklyCheckup>> getAll() async {
    final box = _hive.getBox('weekly_checkups');
    final checkups = box.values
        .map((c) => WeeklyCheckup.fromJson(c as Map))
        .toList();
    checkups.sort((a, b) => b.checkupDate.compareTo(a.checkupDate));
    return checkups;
  }

  Future<WeeklyCheckup?> getById(String id) async {
    final box = _hive.getBox('weekly_checkups');
    final data = box.get(id);
    return data != null ? WeeklyCheckup.fromJson(data) : null;
  }

  Future<void> save(WeeklyCheckup checkup) async {
    final box = _hive.getBox('weekly_checkups');
    checkup.isDirty = true;
    checkup.updatedAt = DateTime.now();
    await box.put(checkup.id, checkup.toJson());
    
    // Auto-sync disabled as per request
    // if (_supabase.auth.currentUser != null) {
    //   await syncOne(checkup);
    // }
  }

  Future<void> syncOne(WeeklyCheckup checkup) async {
    try {
      final box = _hive.getBox('weekly_checkups');
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      final data = {
        'id': checkup.id,
        'server_id': checkup.serverId ?? checkup.id,
        'user_id': currentUser.id,
        'week_start_date': checkup.weekStartDate.toIso8601String(),
        'week_end_date': checkup.weekEndDate.toIso8601String(),
        'checkup_date': checkup.checkupDate.toIso8601String(),
        'total_stock_purchased': checkup.totalStockPurchased,
        'total_sales_revenue': checkup.totalSalesRevenue,
        'total_business_expenses': checkup.totalBusinessExpenses,
        'total_personal_payouts': checkup.totalPersonalPayouts,
        'capital_recovered': checkup.capitalRecovered,
        'capital_remaining': checkup.capitalRemaining,
        'realized_profit': checkup.realizedProfit,
        'profit_payout_taken': checkup.profitPayoutTaken,
        'profit_reinjected': checkup.profitReinjected,
        'notes': checkup.notes,
        'updated_at': checkup.updatedAt.toIso8601String(),
        'deleted_at': checkup.deletedAt?.toIso8601String(),
        'operation_id': checkup.operationId,
        'sales_count': checkup.salesCount,
        'stock_items_count': checkup.stockItemsCount,
        'category_revenue': checkup.categoryRevenue,
        'top_products': checkup.topProducts,
      };

      await _supabase.from('weekly_checkups').upsert(data, onConflict: 'server_id');

      checkup.isDirty = false;
      checkup.lastSyncedAt = DateTime.now();
      await box.put(checkup.id, checkup.toJson());
      logger.info('Synced weekly checkup: ${checkup.operationId}');
    } catch (e, stack) {
      logger.error('Sync weekly checkup failed', e, stack);
    }
  }

  Future<void> pullAll({DateTime? lastSync}) async {
    try {
      final box = _hive.getBox('weekly_checkups');
      var query = _supabase.from('weekly_checkups').select();
      
      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }

      final response = await query;
      
      for (var data in response) {
        final String sId = data['server_id'];

        final existingJson = SyncRecordResolver.findExistingRecord(
          box.values,
          localId: sId,
          serverId: sId,
        );

        if (existingJson != null) {
          final existing = WeeklyCheckup.fromJson(existingJson);
          if (existing.isDirty) {
            logger.info('Skipping pull for dirty weekly checkup: ${existing.operationId}');
            continue;
          }
          final remoteUpdatedAt = DateTime.parse(data['updated_at']);
          if (!remoteUpdatedAt.isAfter(existing.updatedAt)) {
            continue;
          }
        }

        final checkup = existingJson != null
            ? WeeklyCheckup.fromJson(existingJson)
            : WeeklyCheckup(id: SyncRecordResolver.stableLocalId(existingJson: existingJson, remoteServerId: sId));
        checkup.serverId = sId;
        checkup.weekStartDate = DateTime.parse(data['week_start_date']);
        checkup.weekEndDate = DateTime.parse(data['week_end_date']);
        checkup.checkupDate = DateTime.parse(data['checkup_date']);
        checkup.totalStockPurchased = (data['total_stock_purchased'] as num).toDouble();
        checkup.totalSalesRevenue = (data['total_sales_revenue'] as num).toDouble();
        checkup.totalBusinessExpenses = (data['total_business_expenses'] as num).toDouble();
        checkup.totalPersonalPayouts = (data['total_personal_payouts'] as num).toDouble();
        checkup.capitalRecovered = (data['capital_recovered'] as num).toDouble();
        checkup.capitalRemaining = (data['capital_remaining'] as num).toDouble();
        checkup.realizedProfit = (data['realized_profit'] as num).toDouble();
        checkup.profitPayoutTaken = (data['profit_payout_taken'] as num).toDouble();
        checkup.profitReinjected = (data['profit_reinjected'] as num).toDouble();
        checkup.notes = data['notes'];
        checkup.createdAt = DateTime.parse(data['created_at']);
        checkup.updatedAt = DateTime.parse(data['updated_at']);
        checkup.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
        checkup.operationId = data['operation_id'];
        checkup.salesCount = data['sales_count'] ?? 0;
        checkup.stockItemsCount = data['stock_items_count'] ?? 0;
        checkup.categoryRevenue = (data['category_revenue'] as Map?)?.cast<String, double>();
        checkup.topProducts = (data['top_products'] as List?)
            ?.map((e) => (e as Map).cast<String, dynamic>())
            .toList();
        checkup.isDirty = false;
        checkup.lastSyncedAt = DateTime.now();

        await box.put(checkup.id, checkup.toJson());
      }
      logger.info('Pulled all weekly checkups');
    } catch (e, stack) {
      logger.error('Pull weekly checkups failed', e, stack);
    }
  }

  Future<void> softDelete(WeeklyCheckup checkup) async {
    final box = _hive.getBox('weekly_checkups');
    checkup.deletedAt = DateTime.now();
    checkup.updatedAt = DateTime.now();
    checkup.isDirty = true;
    await box.put(checkup.id, checkup.toJson());
  }

  Future<void> delete(WeeklyCheckup checkup) async {
    final box = _hive.getBox('weekly_checkups');
    await box.delete(checkup.id);
  }

  Future<void> syncDirty() async {
    final box = _hive.getBox('weekly_checkups');
    final dirtyRecords = box.values
        .whereType<Map>()
        .map((c) => WeeklyCheckup.fromJson(c))
        .where((c) => c.isDirty && c.id.isNotEmpty)
        .toList();

    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty weekly checkups. Syncing...');
    for (var checkup in dirtyRecords) {
      await syncOne(checkup);
    }
  }

  Future<List<WeeklyCheckup>> getByWeek(DateTime weekStartDate) async {
    final all = await getAll();
    return all.where((c) => 
      c.weekStartDate.year == weekStartDate.year && 
      c.weekStartDate.month == weekStartDate.month && 
      c.weekStartDate.day == weekStartDate.day
    ).toList();
  }

  Future<WeeklyCheckup?> getLatest() async {
    final all = await getAll();
    return all.isNotEmpty ? all.first : null;
  }
}
