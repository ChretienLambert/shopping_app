import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';

class CustomerRepository {
  final _hive = HiveService.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Customer>> getAll() async {
    final box = _hive.customersBox;
    return box.values
        .map((c) => Customer.fromJson(c))
        .where((c) => c.deletedAt == null)
        .toList();
  }

  Future<void> save(Customer customer) async {
    final box = _hive.customersBox;
    customer.isDirty = true;
    customer.updatedAt = DateTime.now();
    
    await box.put(customer.id, customer.toJson());
    await syncOne(customer);
  }

  Future<void> syncOne(Customer customer) async {
    try {
      final box = _hive.customersBox;
      final currentUser = _supabase.auth.currentUser;
      
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

      customer.isDirty = false;
      customer.lastSyncedAt = DateTime.now();
      
      await box.put(customer.id, customer.toJson());
      logger.info('Synced customer: ${customer.name}');
    } catch (e, stack) {
      if (e.toString().contains('42501')) {
         logger.error('RLS Policy Violation', e, stack);
      } else {
         logger.warning('Sync failed for customer ${customer.serverId}: $e');
      }
    }
  }

  Future<void> softDelete(Customer customer) async {
    final box = _hive.customersBox;
    customer.deletedAt = DateTime.now();
    customer.updatedAt = DateTime.now();
    customer.isDirty = true;
    
    await box.put(customer.id, customer.toJson());
    await syncOne(customer);
  }

  Future<void> syncDirty() async {
    final box = _hive.customersBox;
    final dirtyRecords = box.values
        .map((c) => Customer.fromJson(c))
        .where((c) => c.isDirty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty customers. Syncing...');
    for (var customer in dirtyRecords) {
      await syncOne(customer);
    }
  }

  Future<void> pullAll() async {
    try {
      final box = _hive.customersBox;
      final response = await _supabase.from('customers').select();
      
      final List<dynamic> remoteData = response;
      
      for (var data in remoteData) {
        final String sId = data['server_id'];
        
        final existing = box.values
            .map((c) => Customer.fromJson(c))
            .firstWhere((c) => c.serverId == sId, orElse: () => Customer());

        existing.serverId = sId;
        existing.name = data['name'];
        existing.phoneNumber = data['phone_number'];
        existing.email = data['email'];
        existing.address = data['address'];
        existing.notes = data['notes'];
        existing.deletedAt = data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null;
        existing.createdAt = DateTime.parse(data['created_at']);
        existing.updatedAt = DateTime.parse(data['updated_at']);
        existing.isDirty = false;
        existing.lastSyncedAt = DateTime.now();
        
        await box.put(existing.id, existing.toJson());
      }
      logger.info('Pulled all customers from cloud');
    } catch (e, stack) {
      logger.error('Pull all customers failed', e, stack);
    }
  }
}
