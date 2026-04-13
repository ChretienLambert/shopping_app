import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/customer_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/sale_repository.dart';
import '../repositories/expense_repository.dart';
import 'logging_service.dart';

class SyncManager {
  final _connectivity = Connectivity();
  final _supabase = Supabase.instance.client;
  
  final _customerRepo = CustomerRepository();
  final _productRepo = ProductRepository();
  final _saleRepo = SaleRepository();
  final _expenseRepo = ExpenseRepository();
  
  bool _isOnline = false;
  bool _isSyncInProgress = false;
  String? _lastError;

  SyncManager() {
    _init();
  }

  void _init() async {
    await _updateOnlineStatus();
    
    if (_isOnline && _supabase.auth.currentUser != null) {
      syncAll();
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
    await _updateOnlineStatus();
    if (!_isOnline) return 'Device is offline. Check your internet connection.';
    
    try {
      // Smallest possible query to verify table existence and credentials
      await _supabase.from('products').select('id').limit(1);
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
    await _updateOnlineStatus();
    if (!_isOnline || _supabase.auth.currentUser == null) {
      logger.info('Sync skipped: Offline or not logged in.');
      return;
    }
    
    logger.info('Starting full data sync (Pull & Push)...');
    _isSyncInProgress = true;
    
    try {
      // 1. Pull changes from cloud
      await _customerRepo.pullAll();
      await _productRepo.pullAll();
      await _saleRepo.pullAll();
      await _expenseRepo.pullAll();

      // 2. Push local "dirty" changes
      await pushAll();
      
      logger.info('Full data sync completed.');
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

  /// Specialized method for first-time login on a new device.
  /// This ensures the local database is fully populated before usage.
  Future<void> triggerInitialSync() async {
    if (_isSyncInProgress) {
      logger.info('Sync already running. Skipping duplicate initial sync.');
      return;
    }
    await _updateOnlineStatus();
    if (!_isOnline || _supabase.auth.currentUser == null) {
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
    await _updateOnlineStatus();
    if (!_isOnline || _supabase.auth.currentUser == null) {
      logger.info('Push skipped: Offline or not logged in.');
      return;
    }
    
    logger.info('Pushing local changes to cloud...');
    try {
      await _customerRepo.syncDirty();
      await _productRepo.syncDirty();
      await _saleRepo.syncDirty();
      await _expenseRepo.syncDirty();
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

  bool get isOnline => _isOnline;
  String? get lastError => _lastError;

  void dispose() {
  }
}
