import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'isar_service.dart';
import 'logging_service.dart';

class MaintenanceService {
  final _isar = IsarService.instance;
  final _supabase = Supabase.instance.client;

  /// Completely wipes local and remote data for the current user.
  /// USE WITH CAUTION.
  Future<void> completeSystemReset() async {
    logger.warning('SYSTEM RESET INITIATED');
    
    try {
      // 1. Wipe Local Isar
      await _isar.clearAllData();
      logger.info('Local Isar database wiped.');

      // 2. Wipe Remote Supabase tables
      // Note: We use the repositories or direct client to delete all records 
      // where user_id matches or just all (if RLS restricts it to user's data anyway)
      final tables = ['sale_items', 'sales', 'products', 'customers', 'expenses'];
      
      for (final table in tables) {
        try {
          // Delete all rows using a bigint-safe filter.
          await _supabase.from(table).delete().gt('id', -1);
          logger.info('Remote table $table wiped (current user data).');
        } catch (e) {
          logger.error('Failed to wipe remote table $table', e);
        }
      }

      // 3. Reset local app setup/profile state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_setup_completed');
      await prefs.remove('app_language');
      await prefs.remove('finance_initial_capital');
      await prefs.remove('finance_capital_injections');

      logger.info('SYSTEM RESET COMPLETED');
    } catch (e) {
      logger.error('Critical error during system reset', e);
      rethrow;
    }
  }

  /// Wipe local and seed with clothing shop data
  Future<void> resetAndSeedClothingShop() async {
    await _isar.clearAllData();
    await _isar.seedClothingShopData();
  }
}
