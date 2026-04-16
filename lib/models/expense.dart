import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  stock,
  business,
  personalPayout,
}

class Expense {
  String id;
  String? userId; 
  String? serverId;
  bool isDirty;
  DateTime? lastSyncedAt;
  String description;
  double amount;
  ExpenseCategory category;
  DateTime expenseDate;
  String? notes;
  String? receiptImagePath;
  String? stockProductName;
  String? stockProductType;
  String? stockQuality;
  int? stockQuantity;
  double? stockPurchasePrice;
  double? stockResalePrice;
  String? stockImagePath;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
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
      default:
        return ExpenseCategory.business;
    }
  }
}
