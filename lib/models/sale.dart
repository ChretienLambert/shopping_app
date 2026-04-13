import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'sale.g.dart';

enum SaleType { store, delivery }

enum SaleLifecycleStatus { pending, completed }

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

  String? operationId; // Unique operation ID (e.g., S####)

  @Index()
  bool isDelivery = false;

  @Index()
  String status = 'Complete';

  @Index()
  bool isPaid = true; // Default to true for shop sales

  String? deliveryAddress;

  @ignore
  SaleType get saleType => isDelivery ? SaleType.delivery : SaleType.store;

  set saleType(SaleType value) {
    isDelivery = value == SaleType.delivery;
  }

  @ignore
  SaleLifecycleStatus get lifecycleStatus {
    final normalized = status.toLowerCase();
    return normalized == 'pending'
        ? SaleLifecycleStatus.pending
        : SaleLifecycleStatus.completed;
  }

  set lifecycleStatus(SaleLifecycleStatus value) {
    status = value == SaleLifecycleStatus.pending ? 'Pending' : 'Complete';
  }

  @ignore
  bool get isLocked => lifecycleStatus == SaleLifecycleStatus.completed && isPaid;
  
  Sale() {
    serverId = const Uuid().v4();
    saleDate = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    operationId = _generateOperationId();
  }

  static String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'S$random';
  }
}
