// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 6;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String?,
      customerId: fields[1] as String,
      userId: fields[2] as String?,
      serverId: fields[3] as String?,
      isDirty: fields[4] as bool,
      lastSyncedAt: fields[5] as DateTime?,
      totalAmount: fields[6] as double,
      saleDate: fields[7] as DateTime?,
      notes: fields[8] as String?,
      metadataJson: fields[9] as String?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      deletedAt: fields[12] as DateTime?,
      operationId: fields[13] as String?,
      isDelivery: fields[14] as bool,
      status: fields[15] as String,
      isPaid: fields[16] as bool,
      deliveryAddress: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.serverId)
      ..writeByte(4)
      ..write(obj.isDirty)
      ..writeByte(5)
      ..write(obj.lastSyncedAt)
      ..writeByte(6)
      ..write(obj.totalAmount)
      ..writeByte(7)
      ..write(obj.saleDate)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.metadataJson)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.deletedAt)
      ..writeByte(13)
      ..write(obj.operationId)
      ..writeByte(14)
      ..write(obj.isDelivery)
      ..writeByte(15)
      ..write(obj.status)
      ..writeByte(16)
      ..write(obj.isPaid)
      ..writeByte(17)
      ..write(obj.deliveryAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleTypeAdapter extends TypeAdapter<SaleType> {
  @override
  final int typeId = 4;

  @override
  SaleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SaleType.store;
      case 1:
        return SaleType.delivery;
      default:
        return SaleType.store;
    }
  }

  @override
  void write(BinaryWriter writer, SaleType obj) {
    switch (obj) {
      case SaleType.store:
        writer.writeByte(0);
        break;
      case SaleType.delivery:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
