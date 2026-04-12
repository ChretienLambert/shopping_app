import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? serverId; // Supabase/Auth ID
  
  @Index()
  bool isDirty = true; // Needs sync
  
  DateTime? lastSyncedAt;

  @Index(unique: true)
  late String name;

  @Index(unique: true)
  late String email;

  String? localPasswordHash;
  
  String? bio;
  
  String? profileImageUrl;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  User() {
    serverId = const Uuid().v4();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
