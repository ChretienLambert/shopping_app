import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

enum ExpenseCategory {
  socialMedia,
  stand,
  transportation,
  supplies,
  utilities,
  rent,
  marketing,
  other,
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
  
  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  @Index()
  DateTime? deletedAt;
  
  Expense() {
    serverId = const Uuid().v4();
    expenseDate = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
