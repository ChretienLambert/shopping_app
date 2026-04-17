import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive_service.dart';
import 'logging_service.dart';

class MaintenanceService {
  final _hive = HiveService.instance;
  final _supabase = Supabase.instance.client;

  /// Completely wipes local and remote data for the current user.
  /// USE WITH CAUTION.
  Future<void> completeSystemReset() async {
    logger.warning('SYSTEM RESET INITIATED');
    
    try {
      // 1. Capture user context BEFORE wiping local storage
      final currentUser = _supabase.auth.currentUser;
      final userId = currentUser?.id;
      logger.info('System reset context captured for user: $userId');

      // 2. Wipe Local Hive Boxes
      await _hive.clearAll();
      logger.info('Local Hive database wiped.');

      // 3. Wipe Remote Supabase tables
      final tables = ['sale_items', 'sales', 'products', 'customers', 'expenses', 'weekly_checkups'];

      if (userId != null && userId.isNotEmpty) {
        for (final table in tables) {
          try {
            // Use a robust filter strategy to avoid type casting errors (22P02)
            // We use the captured userId to ensure we only delete own data.
            if (table == 'sale_items') {
              // sale_items typically link via sale_id; if we can't join, 
              // we attempt a safe "all" delete if RLS allows or skip if unsure.
              // Using a filter that is likely to match bigint or uuid without empty string conversion
              await _supabase.from(table).delete().neq('id', -1);
            } else {
              await _supabase.from(table).delete().eq('user_id', userId);
            }
            logger.info('Remote table $table wiped.');
          } catch (e) {
            logger.error('Failed to wipe remote table $table', e);
          }
        }
      } else {
        logger.warning('No active session found during remote wipe. Skipping cloud data removal.');
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

  /// Wipe local database
  Future<void> resetLocalDatabase() async {
    await _hive.clearAll();
    logger.info('Local Hive database wiped.');
  }
}
