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
      // 1. Wipe Local Hive Boxes
      await _hive.clearAll();
      logger.info('Local Hive database wiped.');

      // 2. Wipe Remote Supabase tables
      final tables = ['sale_items', 'sales', 'products', 'customers', 'expenses'];
      
      for (final table in tables) {
        try {
          // Delete all rows where id is not empty (uuid string)
          await _supabase.from(table).delete().neq('id', '');
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

  /// Wipe local database
  Future<void> resetLocalDatabase() async {
    await _hive.clearAll();
    logger.info('Local Hive database wiped.');
  }
}
