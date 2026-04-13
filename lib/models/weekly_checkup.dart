import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'weekly_checkup.g.dart';

@collection
class WeeklyCheckup {
  Id id = Isar.autoIncrement;

  @Index()
  int? userId; // The ID of the user who created this checkup
  
  @Index(unique: true, replace: true)
  String? serverId; // Supabase ID
  
  @Index()
  bool isDirty = true; // Needs sync
  
  DateTime? lastSyncedAt;

  @Index()
  late DateTime weekStartDate; // Monday of the week being checked
  
  @Index()
  late DateTime weekEndDate; // Sunday of the week being checked
  
  @Index()
  late DateTime checkupDate; // When the checkup was performed

  // Financial metrics for the week
  @Index()
  late double totalStockPurchased; // Stock expenses during the week
  
  @Index()
  late double totalSalesRevenue; // Sales revenue during the week
  
  @Index()
  late double totalBusinessExpenses; // Business expenses during the week
  
  @Index()
  late double totalPersonalPayouts; // Personal payouts during the week
  
  @Index()
  late double capitalRecovered; // Capital recovered from sales this week
  
  @Index()
  late double capitalRemaining; // Capital remaining to recover
  
  @Index()
  late double realizedProfit; // Profit realized this week
  
  @Index()
  late double profitPayoutTaken; // Amount taken as payout
  
  @Index()
  late double profitReinjected; // Amount reinjected as capital
  
  String? notes; // Optional notes about the week

  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;

  @Index()
  DateTime? deletedAt;

  String? operationId; // Unique operation ID (e.g., WC####)

  WeeklyCheckup() {
    serverId = const Uuid().v4();
    checkupDate = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    operationId = _generateOperationId();
  }

  static String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'WC$random';
  }

  // Get the Monday of the week for a given date
  static DateTime getWeekStartDate(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get the Sunday of the week for a given date
  static DateTime getWeekEndDate(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }
}
