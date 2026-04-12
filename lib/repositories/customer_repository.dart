import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import '../services/isar_service.dart';
import '../services/logging_service.dart';

class CustomerRepository {
  final _isar = IsarService.instance;
  final _supabase = Supabase.instance.client;

  // Get all customers (Local first)
  Future<List<Customer>> getAll() async {
    final db = await _isar.isar;
    return await db.customers.filter().deletedAtIsNull().findAll();
  }

  // Add/Update customer
  Future<void> save(Customer customer) async {
    final db = await _isar.isar;
    
    // Save locally first
    customer.isDirty = true;
    customer.updatedAt = DateTime.now();
    
    await db.writeTxn(() async {
      await db.customers.put(customer);
    });

    // Strategy: Attempt to push to Supabase if online
    await syncOne(customer);
  }

  // Push a single record to Supabase
  Future<void> syncOne(Customer customer) async {
    try {
      final db = await _isar.isar;
      final currentUser = _supabase.auth.currentUser;
      
      // Prevent sync if not authenticated (Guest Mode)
      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      final data = {
        'server_id': customer.serverId,
        'user_id': currentUser.id,
        'name': customer.name,
        'phone_number': customer.phoneNumber,
        'email': customer.email,
        'address': customer.address,
        'notes': customer.notes,
        'deleted_at': customer.deletedAt?.toIso8601String(),
        'updated_at': customer.updatedAt.toIso8601String(),
      };

      await _supabase.from('customers').upsert(data, onConflict: 'server_id');

      // Mark as synced
      customer.isDirty = false;
      customer.lastSyncedAt = DateTime.now();
      
      await db.writeTxn(() async {
        await db.customers.put(customer);
      });
      logger.info('Synced customer: ${customer.name}');
    } catch (e) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation: Ensure you are logged in and own this record', e);
      } else {
         logger.warning('Sync failed for customer ${customer.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Customer customer) async {
    final db = await _isar.isar;
    customer.deletedAt = DateTime.now();
    customer.updatedAt = DateTime.now();
    customer.isDirty = true;
    
    await db.writeTxn(() async {
      await db.customers.put(customer);
    });
    
    await syncOne(customer);
  }

  Future<void> syncDirty() async {
    final db = await _isar.isar;
    final dirtyRecords = await db.customers.filter().isDirtyEqualTo(true).findAll();
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty customers. Syncing...');
    for (var record in dirtyRecords) {
      await syncOne(record);
    }
  }

  // Pull all from Supabase and merge locally
  Future<void> pullAll() async {
    try {
      final db = await _isar.isar;
      final response = await _supabase.from('customers').select();
      
      final List<dynamic> remoteData = response;
      
      await db.writeTxn(() async {
        for (var data in remoteData) {
          final String sId = data['server_id']; // Use server_id from remote
          final existing = await db.customers.filter().serverIdEqualTo(sId).findFirst();
          
          final customer = existing ?? Customer();
          customer.serverId = sId;
          customer.name = data['name'];
          customer.phoneNumber = data['phone_number'];
          customer.email = data['email'];
          customer.address = data['address'];
          customer.notes = data['notes'];
          customer.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
          customer.createdAt = DateTime.parse(data['created_at']);
          customer.updatedAt = DateTime.parse(data['updated_at']);
          customer.isDirty = false;
          customer.lastSyncedAt = DateTime.now();
          
          await db.customers.put(customer);
        }
      });
      logger.info('Pulled all customers from cloud');
    } catch (e) {
      logger.error('Pull all customers failed', e);
    }
  }
}
