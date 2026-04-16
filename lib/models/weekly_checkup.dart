import 'package:uuid/uuid.dart';

class WeeklyCheckup {
  String id;
  String? userId;
  String? serverId;
  bool isDirty;
  DateTime? lastSyncedAt;
  DateTime weekStartDate;
  DateTime weekEndDate;
  DateTime checkupDate;
  double totalStockPurchased;
  double totalSalesRevenue;
  double totalBusinessExpenses;
  double totalPersonalPayouts;
  double capitalRecovered;
  double capitalRemaining;
  double realizedProfit;
  double profitPayoutTaken;
  double profitReinjected;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  String? operationId;

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
      );
}
