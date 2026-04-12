import 'package:supabase_flutter/supabase_flutter.dart';
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
          // Attempting to delete all rows. 
          // If RLS is enabled, it will only delete the user's data.
          // Using a high-range eq/neq to simulate "all"
          await _supabase.from(table).delete().neq('id', '00000000-0000-0000-0000-000000000000');
          logger.info('Remote table $table wiped (current user data).');
        } catch (e) {
          logger.error('Failed to wipe remote table $table', e);
        }
      }

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
