import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 4)
enum SaleType { 
  @HiveField(0)
  store, 
  @HiveField(1)
  delivery 
}

@HiveType(typeId: 6)
class Sale {
  @HiveField(0)
  String id;
  @HiveField(1)
  String customerId;
  @HiveField(2)
  String? userId; // The ID of the user who created this sale
  @HiveField(3)
  String? serverId; // Supabase ID
  @HiveField(4)
  bool isDirty;
  @HiveField(5)
  DateTime? lastSyncedAt;
  @HiveField(6)
  double totalAmount;
  @HiveField(7)
  DateTime saleDate;
  @HiveField(8)
  String? notes;
  @HiveField(9)
  String? metadataJson;
  @HiveField(10)
  DateTime createdAt;
  @HiveField(11)
  DateTime updatedAt;
  @HiveField(12)
  DateTime? deletedAt;
  @HiveField(13)
  String operationId;
  @HiveField(14)
  bool isDelivery;
  @HiveField(15)
  String status;
  @HiveField(16)
  bool isPaid;
  @HiveField(17)
  String? deliveryAddress;

  SaleType get saleType => isDelivery ? SaleType.delivery : SaleType.store;
  set saleType(SaleType value) => isDelivery = (value == SaleType.delivery);

  SaleLifecycleStatus get lifecycleStatus {
    return status.toLowerCase() == 'pending'
        ? SaleLifecycleStatus.pending
        : SaleLifecycleStatus.completed;
  }
  set lifecycleStatus(SaleLifecycleStatus value) {
    status = (value == SaleLifecycleStatus.pending) ? 'Pending' : 'Complete';
  }

  bool get isLocked => (lifecycleStatus == SaleLifecycleStatus.completed && isPaid);

  Sale({
    String? id,
    this.customerId = '',
    this.userId,
    this.serverId,
    this.isDirty = true,
    this.lastSyncedAt,
    this.totalAmount = 0.0,
    DateTime? saleDate,
    this.notes,
    this.metadataJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    String? operationId,
    this.isDelivery = false,
    this.status = 'Complete',
    this.isPaid = true,
    this.deliveryAddress,
  })  : id = id ?? const Uuid().v4(),
        saleDate = saleDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        operationId = operationId ?? _generateOperationId();

  static String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'S$random';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'userId': userId,
        'serverId': serverId,
        'isDirty': isDirty,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'totalAmount': totalAmount,
        'saleDate': saleDate.toIso8601String(),
        'notes': notes,
        'metadataJson': metadataJson,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'operationId': operationId,
        'isDelivery': isDelivery,
        'status': status,
        'isPaid': isPaid,
        'deliveryAddress': deliveryAddress,
      };

  factory Sale.fromJson(Map<dynamic, dynamic> json) => Sale(
        id: json['id'],
        customerId: json['customerId'] ?? '',
        userId: json['userId'],
        serverId: json['serverId'],
        isDirty: json['isDirty'] ?? true,
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
        totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
        saleDate: json['saleDate'] != null ? DateTime.parse(json['saleDate']) : null,
        notes: json['notes'],
        metadataJson: json['metadataJson'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
        operationId: json['operationId'],
        isDelivery: json['isDelivery'] ?? false,
        status: json['status'] ?? 'Complete',
        isPaid: json['isPaid'] ?? true,
        deliveryAddress: json['deliveryAddress'],
      );
}

enum SaleLifecycleStatus { pending, completed }
