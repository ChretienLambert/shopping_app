// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_checkup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyCheckupAdapter extends TypeAdapter<WeeklyCheckup> {
  @override
  final int typeId = 5;

  @override
  WeeklyCheckup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyCheckup(
      id: fields[0] as String?,
      userId: fields[1] as String?,
      serverId: fields[2] as String?,
      isDirty: fields[3] as bool,
      lastSyncedAt: fields[4] as DateTime?,
      weekStartDate: fields[5] as DateTime?,
      weekEndDate: fields[6] as DateTime?,
      checkupDate: fields[7] as DateTime?,
      totalStockPurchased: fields[8] as double,
      totalSalesRevenue: fields[9] as double,
      totalBusinessExpenses: fields[10] as double,
      totalPersonalPayouts: fields[11] as double,
      capitalRecovered: fields[12] as double,
      capitalRemaining: fields[13] as double,
      realizedProfit: fields[14] as double,
      profitPayoutTaken: fields[15] as double,
      profitReinjected: fields[16] as double,
      notes: fields[17] as String?,
      createdAt: fields[18] as DateTime?,
      updatedAt: fields[19] as DateTime?,
      deletedAt: fields[20] as DateTime?,
      operationId: fields[21] as String?,
      salesCount: fields[22] as int,
      stockItemsCount: fields[23] as int,
      categoryRevenue: (fields[24] as Map?)?.cast<String, double>(),
      topProducts: (fields[25] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyCheckup obj) {
    writer
      ..writeByte(26)
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
      ..write(obj.weekStartDate)
      ..writeByte(6)
      ..write(obj.weekEndDate)
      ..writeByte(7)
      ..write(obj.checkupDate)
      ..writeByte(8)
      ..write(obj.totalStockPurchased)
      ..writeByte(9)
      ..write(obj.totalSalesRevenue)
      ..writeByte(10)
      ..write(obj.totalBusinessExpenses)
      ..writeByte(11)
      ..write(obj.totalPersonalPayouts)
      ..writeByte(12)
      ..write(obj.capitalRecovered)
      ..writeByte(13)
      ..write(obj.capitalRemaining)
      ..writeByte(14)
      ..write(obj.realizedProfit)
      ..writeByte(15)
      ..write(obj.profitPayoutTaken)
      ..writeByte(16)
      ..write(obj.profitReinjected)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.deletedAt)
      ..writeByte(21)
      ..write(obj.operationId)
      ..writeByte(22)
      ..write(obj.salesCount)
      ..writeByte(23)
      ..write(obj.stockItemsCount)
      ..writeByte(24)
      ..write(obj.categoryRevenue)
      ..writeByte(25)
      ..write(obj.topProducts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyCheckupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
