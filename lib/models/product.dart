import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? serverId; // Supabase ID
  
  @Index()
  bool isDirty = true; // Needs sync
  
  DateTime? lastSyncedAt;

  late String name;
  
  late String description;
  
  @Index()
  late double price;

  @Index()
  double purchasePrice = 0;
  
  @Index()
  late int stockQuantity;
  
  String? imagePath;

  String? productType;

  String? quality;
  
  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  @Index()
  DateTime? deletedAt;
  
  Product() {
    serverId = const Uuid().v4();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
