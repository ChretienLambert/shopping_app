// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String?,
      userId: fields[1] as String?,
      serverId: fields[2] as String?,
      isDirty: fields[3] as bool,
      lastSyncedAt: fields[4] as DateTime?,
      description: fields[5] as String,
      amount: fields[6] as double,
      category: fields[7] as ExpenseCategory,
      expenseDate: fields[8] as DateTime?,
      notes: fields[9] as String?,
      receiptImagePath: fields[10] as String?,
      stockProductName: fields[11] as String?,
      stockProductType: fields[12] as String?,
      stockQuality: fields[13] as String?,
      stockQuantity: fields[14] as int?,
      stockPurchasePrice: fields[15] as double?,
      stockResalePrice: fields[16] as double?,
      stockImagePath: fields[17] as String?,
      createdAt: fields[18] as DateTime?,
      updatedAt: fields[19] as DateTime?,
      deletedAt: fields[20] as DateTime?,
      operationId: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.serverId)
      ..writeByte(3)
      ..write(obj.isDirty)
      ..writeByte(4)
      ..write(obj.lastSyncedAt)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.expenseDate)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.receiptImagePath)
      ..writeByte(11)
      ..write(obj.stockProductName)
      ..writeByte(12)
      ..write(obj.stockProductType)
      ..writeByte(13)
      ..write(obj.stockQuality)
      ..writeByte(14)
      ..write(obj.stockQuantity)
      ..writeByte(15)
      ..write(obj.stockPurchasePrice)
      ..writeByte(16)
      ..write(obj.stockResalePrice)
      ..writeByte(17)
      ..write(obj.stockImagePath)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.deletedAt)
      ..writeByte(21)
      ..write(obj.operationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 2;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.stock;
      case 1:
        return ExpenseCategory.business;
      case 2:
        return ExpenseCategory.personalPayout;
      case 3:
        return ExpenseCategory.capitalInjection;
      default:
        return ExpenseCategory.stock;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.stock:
        writer.writeByte(0);
        break;
      case ExpenseCategory.business:
        writer.writeByte(1);
        break;
      case ExpenseCategory.personalPayout:
        writer.writeByte(2);
        break;
      case ExpenseCategory.capitalInjection:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
