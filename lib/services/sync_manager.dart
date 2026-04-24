import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/customer_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/sale_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/weekly_checkup_repository.dart';
import '../providers/customer_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../services/hive_service.dart';
import 'app_config.dart';
import 'logging_service.dart';

class SyncManager {
  SyncManager(this._config, this._ref) {
    _init();
  }

  final AppConfig _config;
  final Ref _ref;
  final _connectivity = Connectivity();
  
  final _customerRepo = CustomerRepository();
  final _productRepo = ProductRepository();
  final _saleRepo = SaleRepository();
  final _expenseRepo = ExpenseRepository();

  bool _isOnline = false;
  bool _isSyncInProgress = false;
  String? _lastError;
  Timer? _periodicSyncTimer;

  void _init() async {
    // Start periodic background sync every 3 minutes for workstation parity
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (!_isSyncInProgress) {
        syncAll();
      }
    });
  }

  void refreshAppProviders() {
    _ref.invalidate(customerProvider);
    _ref.invalidate(productProvider);
    _ref.invalidate(saleProvider);
    _ref.invalidate(expenseProvider);
    logger.info('App providers refreshed after sync.');
  }

  SupabaseClient? get _supabase {
    if (!_config.hasSupabaseConfig) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateOnlineStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      bool online = hasConnection;
      
      // Verification step for unreliable Windows connectivity reporting
      if (!online) {
        try {
          final lookup = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
          online = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
        } catch (_) {
          online = false;
        }
      }
      
      _isOnline = online;
    } catch (e) {
      _isOnline = true; // Fallback to true and let Supabase calls fail naturally
      logger.warning('Connectivity check failed, assuming online: $e');
    }
  }

  /// Tests connectivity by performing a simple query.
  /// Returns null if successful, or an error message if failed.
  Future<String?> checkConnection() async {
    if (!_config.hasSupabaseConfig) {
      return 'Cloud sync is disabled because Supabase config is missing.';
    }

    await _updateOnlineStatus();
    if (!_isOnline) return 'Device is offline. Check your internet connection.';
    
    try {
      final client = _supabase;
      if (client == null) {
        return 'Supabase client is unavailable.';
      }
      // Added timeout to prevent hanging on flaky connections
      await client.from('products').select('id').limit(1).timeout(const Duration(seconds: 10));
      _lastError = null;
      return null;
    } catch (e) {
      _lastError = e.toString();
      logger.error('Connection check failed', e);
      return _lastError;
    }
  }

  Future<void> syncAll() async {
    if (_isSyncInProgress) {
      logger.info('Sync already running. Skipping duplicate syncAll call.');
      return;
    }
    final client = _supabase;
    await _updateOnlineStatus();
    if (!_isOnline || client?.auth.currentUser == null) {
      logger.info('Sync skipped: Offline or not logged in.');
      return;
    }
    
    logger.info('Starting incremental data sync (Pull & Push)...');
    _isSyncInProgress = true;
    
    try {
      final settings = HiveService.instance.settingsBox;
      final lastSyncStr = settings.get('last_synced_at') as String?;
      final DateTime? lastSync = lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;
      final syncStartedAt = DateTime.now();

      // Pull records updated after local latest
      await _customerRepo.pullAll(lastSync: lastSync);
      await _productRepo.pullAll(lastSync: lastSync);
      await _saleRepo.pullAll(lastSync: lastSync);
      await _expenseRepo.pullAll(lastSync: lastSync);
      await _weeklyRepo.pullAll(lastSync: lastSync);
      
      // Push local "dirty" changes
      await pushAll();

      // Reconcile once more after push so locally-created offline records pick up
      // remote identifiers and any server-side updates in the same sync session.
      await _customerRepo.pullAll(lastSync: lastSync);
      await _productRepo.pullAll(lastSync: lastSync);
      await _saleRepo.pullAll(lastSync: lastSync);
      await _expenseRepo.pullAll(lastSync: lastSync);
      await _weeklyRepo.pullAll(lastSync: lastSync);
      
      // Save sync timestamp
      await settings.put('last_synced_at', syncStartedAt.toIso8601String());

      refreshAppProviders();
      logger.info('Sync process completed.');
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      // Check if error is network-related
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') || errorStr.contains('host lookup') || errorStr.contains('network')) {
        logger.info('Sync failed due to network issue (offline): $e');
        _isOnline = false; // Update online status based on failure
      } else {
        logger.error('Full sync failed', e);
      }
    } finally {
      _isSyncInProgress = false;
    }
  }

  // Adding _weeklyRepo to SyncManager
  final _weeklyRepo = WeeklyCheckupRepository();


  /// Specialized method for first-time login on a new device.
  /// This ensures the local database is fully populated before usage.
  Future<void> triggerInitialSync() async {
    if (_isSyncInProgress) {
      logger.info('Sync already running. Skipping duplicate initial sync.');
      return;
    }
    final client = _supabase;
    await _updateOnlineStatus();
    if (!_isOnline || client?.auth.currentUser == null) {
      logger.warning('Cannot perform initial sync: Offline or not logged in.');
      return;
    }

    logger.info('🚀 Triggering Initial Data Pull...');
    _isSyncInProgress = true;
    try {
      await _customerRepo.pullAll();
      await _productRepo.pullAll();
      await _saleRepo.pullAll();
      await _expenseRepo.pullAll();
      await _weeklyRepo.pullAll();
      
      refreshAppProviders();
      logger.info('✅ Initial Pull Completed.');
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      logger.error('❌ Initial Pull Failed', e);
      rethrow;
    } finally {
      _isSyncInProgress = false;
    }
  }

  Future<void> pushAll() async {
    final client = _supabase;
    await _updateOnlineStatus();
    if (!_isOnline || client?.auth.currentUser == null) {
      logger.info('Push skipped: Offline or not logged in.');
      return;
    }
    
    logger.info('Pushing local changes to cloud...');
    try {
      await _customerRepo.syncDirty();
      await _productRepo.syncDirty();
      await _saleRepo.syncDirty();
      await _expenseRepo.syncDirty();
      await _weeklyRepo.syncDirty();

      logger.info('Push completed.');
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      // Check if error is network-related
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') || errorStr.contains('host lookup') || errorStr.contains('network')) {
        logger.info('Push failed due to network issue (offline): $e');
        _isOnline = false; // Update online status based on failure
      } else {
        logger.error('Push failed', e);
      }
    }
  }

  Future<void> pullAll() async {
    final client = _supabase;
    await _updateOnlineStatus();
    if (!_isOnline || client?.auth.currentUser == null) {
      logger.info('Pull skipped: Offline or not logged in.');
      return;
    }

    logger.info('Pull remote changes from cloud (Full scan)...');
    try {
      // We pull everything to ensure local is up to date with DB "Source of Truth"
      await _customerRepo.pullAll();
      await _productRepo.pullAll();
      await _saleRepo.pullAll();
      await _expenseRepo.pullAll();
      await _weeklyRepo.pullAll();

      refreshAppProviders();
      logger.info('Pull completed.');
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      logger.error('Pull failed', e);
    }
  }

  bool get isOnline => _isOnline;
  String? get lastError => _lastError;

  void dispose() {
    _periodicSyncTimer?.cancel();
  }
}
