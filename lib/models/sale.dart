import 'package:uuid/uuid.dart';

enum SaleType { store, delivery }

enum SaleLifecycleStatus { pending, completed }

class Sale {
  String id;
  String customerId;
  String? userId; // The ID of the user who created this sale
  String? serverId; // Supabase ID
  bool isDirty;
  DateTime? lastSyncedAt;
  double totalAmount;
  DateTime saleDate;
  String? notes;
  String? metadataJson;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  String operationId;
  bool isDelivery;
  String status;
  bool isPaid;
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
