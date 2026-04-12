import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'sale.g.dart';

@collection
class Sale {
  Id id = Isar.autoIncrement;

  @Index()
  late int customerId;

  @Index()
  int? userId; // The ID of the user who created this sale
  
  @Index(unique: true, replace: true)
  String? serverId; // Supabase ID
  
  @Index()
  bool isDirty = true; // Needs sync
  
  DateTime? lastSyncedAt;
  
  @Index()
  late double totalAmount;
  
  @Index()
  late DateTime saleDate;
  
  String? notes;

  /// Stores arbitrary metadata like payment method, shop location, etc. as JSON
  String? metadataJson;

  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;

  @Index()
  DateTime? deletedAt;

  @Index()
  bool isDelivery = false;

  @Index()
  String status = 'Complete';

  @Index()
  bool isPaid = true; // Default to true for shop sales

  String? deliveryAddress;

  @ignore
  bool get isLocked => (status == 'Delivered' || status == 'Complete') && isPaid;
  
  Sale() {
    serverId = const Uuid().v4();
    saleDate = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
