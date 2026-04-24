import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import '../services/hive_service.dart';
import '../services/logging_service.dart';
import '../services/sync_record_resolver.dart';

class CustomerRepository {
  final _hive = HiveService.instance;
  
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

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
  }

  Future<void> syncOne(Customer customer) async {
    final client = _supabase;
    if (client == null) {
      logger.warning('Sync skipped: Supabase not initialized');
      return;
    }

    try {
      final box = _hive.customersBox;
      final currentUser = client.auth.currentUser;
      
      if (currentUser == null) {
        logger.info('Sync skipped (No authenticated user)');
        return;
      }

      final data = {
        'id': customer.id,
        'server_id': customer.serverId ?? customer.id,
        'user_id': currentUser.id,
        'name': customer.name,
        'phone_number': customer.phoneNumber,
        'email': customer.email,
        'address': customer.address,
        'notes': customer.notes,
        'deleted_at': customer.deletedAt?.toIso8601String(),
        'updated_at': customer.updatedAt.toIso8601String(),
      };

      final response = await client
          .from('customers')
          .upsert(data, onConflict: 'server_id')
          .select()
          .single();

      customer.serverId = response['server_id'];
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
  }

  Future<void> syncDirty() async {
    final box = _hive.customersBox;
    final dirtyRecords = box.values
        .whereType<Map>()
        .map((c) => Customer.fromJson(c))
        .where((c) => c.isDirty && c.id.isNotEmpty)
        .toList();
    
    if (dirtyRecords.isEmpty) return;

    logger.info('Found ${dirtyRecords.length} dirty customers. Syncing...');
    for (var customer in dirtyRecords) {
      await syncOne(customer);
    }
  }

  Future<void> pullAll({DateTime? lastSync}) async {
    final client = _supabase;
    if (client == null) return;

    try {
      final box = _hive.customersBox;
      var query = client.from('customers').select();
      
      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }
      
      final response = await query;
      final List<dynamic> remoteData = response;
      logger.info('Fetched ${remoteData.length} customers from Supabase');
      
      for (var data in remoteData) {
        final String sId = data['server_id'];

        final existingJson = SyncRecordResolver.findExistingRecord(
          box.values,
          localId: sId,
          serverId: sId,
        );
        
        if (existingJson != null) {
          final existing = Customer.fromJson(existingJson);
          final remoteUpdatedAt = DateTime.parse(data['updated_at']);
          
          // If remote is newer, it wins (User says DB is correct one)
          if (!remoteUpdatedAt.isAfter(existing.updatedAt)) {
            continue;
          }
        }

        final customer = existingJson != null
            ? Customer.fromJson(existingJson)
            : Customer(id: SyncRecordResolver.stableLocalId(existingJson: existingJson, remoteServerId: sId));
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
        
        await box.put(customer.id, customer.toJson());
      }
      logger.info('Pulled all customers from cloud');
    } catch (e, stack) {
      logger.error('Pull all customers failed', e, stack);
    }
  }
}
