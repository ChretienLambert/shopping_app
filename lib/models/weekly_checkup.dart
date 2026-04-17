import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'weekly_checkup.g.dart';

@HiveType(typeId: 5)
class WeeklyCheckup {
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
  DateTime weekStartDate;
  @HiveField(6)
  DateTime weekEndDate;
  @HiveField(7)
  DateTime checkupDate;
  @HiveField(8)
  double totalStockPurchased;
  @HiveField(9)
  double totalSalesRevenue;
  @HiveField(10)
  double totalBusinessExpenses;
  @HiveField(11)
  double totalPersonalPayouts;
  @HiveField(12)
  double capitalRecovered;
  @HiveField(13)
  double capitalRemaining;
  @HiveField(14)
  double realizedProfit;
  @HiveField(15)
  double profitPayoutTaken;
  @HiveField(16)
  double profitReinjected;
  @HiveField(17)
  String? notes;
  @HiveField(18)
  DateTime createdAt;
  @HiveField(19)
  DateTime updatedAt;
  @HiveField(20)
  DateTime? deletedAt;
  @HiveField(21)
  String? operationId;

  // Analytics fields
  @HiveField(22)
  int salesCount;
  @HiveField(23)
  int stockItemsCount;
  @HiveField(24)
  Map<String, double>? categoryRevenue;
  @HiveField(25)
  List<Map<String, dynamic>>? topProducts;

  WeeklyCheckup({
    String? id,
    this.userId,
    this.serverId,
    this.isDirty = true,
    this.lastSyncedAt,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    DateTime? checkupDate,
    this.totalStockPurchased = 0.0,
    this.totalSalesRevenue = 0.0,
    this.totalBusinessExpenses = 0.0,
    this.totalPersonalPayouts = 0.0,
    this.capitalRecovered = 0.0,
    this.capitalRemaining = 0.0,
    this.realizedProfit = 0.0,
    this.profitPayoutTaken = 0.0,
    this.profitReinjected = 0.0,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.operationId,
    this.salesCount = 0,
    this.stockItemsCount = 0,
    this.categoryRevenue,
    this.topProducts,
  })  : id = id ?? const Uuid().v4(),
        weekStartDate = weekStartDate ?? DateTime.now(),
        weekEndDate = weekEndDate ?? DateTime.now(),
        checkupDate = checkupDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    operationId ??= _generateOperationId();
  }

  static String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'WC$random';
  }

  static DateTime getWeekStartDate(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getWeekEndDate(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'serverId': serverId,
        'isDirty': isDirty,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'weekStartDate': weekStartDate.toIso8601String(),
        'weekEndDate': weekEndDate.toIso8601String(),
        'checkupDate': checkupDate.toIso8601String(),
        'totalStockPurchased': totalStockPurchased,
        'totalSalesRevenue': totalSalesRevenue,
        'totalBusinessExpenses': totalBusinessExpenses,
        'totalPersonalPayouts': totalPersonalPayouts,
        'capitalRecovered': capitalRecovered,
        'capitalRemaining': capitalRemaining,
        'realizedProfit': realizedProfit,
        'profitPayoutTaken': profitPayoutTaken,
        'profitReinjected': profitReinjected,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'operationId': operationId,
        'salesCount': salesCount,
        'stockItemsCount': stockItemsCount,
        'categoryRevenue': categoryRevenue,
        'topProducts': topProducts,
      };

  factory WeeklyCheckup.fromJson(Map<dynamic, dynamic> json) => WeeklyCheckup(
        id: json['id'],
        userId: json['userId'],
        serverId: json['serverId'],
        isDirty: json['isDirty'] ?? true,
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
        weekStartDate: json['weekStartDate'] != null ? DateTime.parse(json['weekStartDate']) : null,
        weekEndDate: json['weekEndDate'] != null ? DateTime.parse(json['weekEndDate']) : null,
        checkupDate: json['checkupDate'] != null ? DateTime.parse(json['checkupDate']) : null,
        totalStockPurchased: (json['totalStockPurchased'] ?? 0.0).toDouble(),
        totalSalesRevenue: (json['totalSalesRevenue'] ?? 0.0).toDouble(),
        totalBusinessExpenses: (json['totalBusinessExpenses'] ?? 0.0).toDouble(),
        totalPersonalPayouts: (json['totalPersonalPayouts'] ?? 0.0).toDouble(),
        capitalRecovered: (json['capitalRecovered'] ?? 0.0).toDouble(),
        capitalRemaining: (json['capitalRemaining'] ?? 0.0).toDouble(),
        realizedProfit: (json['realizedProfit'] ?? 0.0).toDouble(),
        profitPayoutTaken: (json['profitPayoutTaken'] ?? 0.0).toDouble(),
        profitReinjected: (json['profitReinjected'] ?? 0.0).toDouble(),
        notes: json['notes'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
        operationId: json['operationId'],
        salesCount: json['salesCount'] ?? 0,
        stockItemsCount: json['stockItemsCount'] ?? 0,
        categoryRevenue: (json['categoryRevenue'] as Map?)?.cast<String, double>(),
        topProducts: (json['topProducts'] as List?)
            ?.map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
      );
}
