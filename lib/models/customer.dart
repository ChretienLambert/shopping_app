import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@collection
class Customer {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? serverId; // Supabase ID
  
  @Index()
  bool isDirty = true; // Needs sync
  
  DateTime? lastSyncedAt;

  late String name;
  
  String? phoneNumber;
  
  String? email;
  
  String? address;
  
  String? notes;
  
  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  @Index()
  DateTime? deletedAt;
  
  Customer() {
    serverId = const Uuid().v4();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
