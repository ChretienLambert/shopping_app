import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
enum ExpenseCategory {
  @HiveField(0)
  stock,
  @HiveField(1)
  business,
  @HiveField(2)
  personalPayout,
  @HiveField(3)
  capitalInjection,
}

@HiveType(typeId: 1)
class Expense {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? userId; 
  @HiveField(2)
  String? serverId;
  @HiveField(3)
  bool isDirty;
  @HiveField(4)
  DateTime? lastSyncedAt;
  @HiveField(5)
  String description;
  @HiveField(6)
  double amount;
  @HiveField(7)
  ExpenseCategory category;
  @HiveField(8)
  DateTime expenseDate;
  @HiveField(9)
  String? notes;
  @HiveField(10)
  String? receiptImagePath;
  @HiveField(11)
  String? stockProductName;
  @HiveField(12)
  String? stockProductType;
  @HiveField(13)
  String? stockQuality;
  @HiveField(14)
  int? stockQuantity;
  @HiveField(15)
  double? stockPurchasePrice;
  @HiveField(16)
  double? stockResalePrice;
  @HiveField(17)
  String? stockImagePath;
  @HiveField(18)
  DateTime createdAt;
  @HiveField(19)
  DateTime updatedAt;
  @HiveField(20)
  DateTime? deletedAt;
  @HiveField(21)
  String? operationId;

  Expense({
    String? id,
    this.userId,
    this.serverId,
    this.isDirty = true,
    this.lastSyncedAt,
    this.description = '',
    this.amount = 0.0,
    this.category = ExpenseCategory.business,
    DateTime? expenseDate,
    this.notes,
    this.receiptImagePath,
    this.stockProductName,
    this.stockProductType,
    this.stockQuality,
    this.stockQuantity,
    this.stockPurchasePrice,
    this.stockResalePrice,
    this.stockImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.operationId,
  })  : id = id ?? const Uuid().v4(),
        expenseDate = expenseDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    operationId ??= _generateOperationId();
  }

  static String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'EX$random';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'serverId': serverId,
        'isDirty': isDirty,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'description': description,
        'amount': amount,
        'category': category.name,
        'expenseDate': expenseDate.toIso8601String(),
        'notes': notes,
        'receiptImagePath': receiptImagePath,
        'stockProductName': stockProductName,
        'stockProductType': stockProductType,
        'stockQuality': stockQuality,
        'stockQuantity': stockQuantity,
        'stockPurchasePrice': stockPurchasePrice,
        'stockResalePrice': stockResalePrice,
        'stockImagePath': stockImagePath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'operationId': operationId,
      };

  factory Expense.fromJson(Map<dynamic, dynamic> json) => Expense(
        id: json['id'],
        userId: json['userId'],
        serverId: json['serverId'],
        isDirty: json['isDirty'] ?? true,
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
        description: json['description'] ?? '',
        amount: (json['amount'] ?? 0.0).toDouble(),
        category: _parseCategory(json['category'] ?? 'business'),
        expenseDate: json['expenseDate'] != null ? DateTime.parse(json['expenseDate']) : null,
        notes: json['notes'],
        receiptImagePath: json['receiptImagePath'],
        stockProductName: json['stockProductName'],
        stockProductType: json['stockProductType'],
        stockQuality: json['stockQuality'],
        stockQuantity: json['stockQuantity'],
        stockPurchasePrice: (json['stockPurchasePrice'] as num?)?.toDouble(),
        stockResalePrice: (json['stockResalePrice'] as num?)?.toDouble(),
        stockImagePath: json['stockImagePath'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
        operationId: json['operationId'],
      );

  static ExpenseCategory _parseCategory(String category) {
    switch (category) {
      case 'stock':
        return ExpenseCategory.stock;
      case 'business':
        return ExpenseCategory.business;
      case 'personalPayout':
        return ExpenseCategory.personalPayout;
      case 'capitalInjection':
        return ExpenseCategory.capitalInjection;
      default:
        return ExpenseCategory.business;
    }
  }
}
