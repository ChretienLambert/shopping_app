import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

enum ExpenseCategory {
  stock,
  business,
  personalPayout,
}

@collection
class Expense {
  Id id = Isar.autoIncrement;

  @Index()
  int? userId; // The ID of the user who created this expense
  
  @Index(unique: true, replace: true)
  String? serverId; // Supabase ID
  
  @Index()
  bool isDirty = true; // Needs sync
  
  DateTime? lastSyncedAt;

  late String description;
  
  @Index()
  late double amount;
  
  @enumerated
  @Index()
  late ExpenseCategory category;
  
  @Index()
  late DateTime expenseDate;
  
  String? notes;
  
  String? receiptImagePath;

  // Stock expense details (used when category == stock)
  String? stockProductName;
  String? stockProductType;
  String? stockQuality;
  int? stockQuantity;
  double? stockPurchasePrice;
  double? stockResalePrice;
  String? stockImagePath;
  
  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  @Index()
  DateTime? deletedAt;

  String? operationId; // Unique operation ID (e.g., EX####)

  Expense() {
    serverId = const Uuid().v4();
    expenseDate = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    operationId = _generateOperationId();
  }

  static String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'EX$random';
  }
}
