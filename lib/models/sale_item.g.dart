// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 7;

  @override
  SaleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItem(
      id: fields[0] as String?,
      serverId: fields[1] as String?,
      saleId: fields[2] as String,
      productId: fields[3] as String,
      quantity: fields[4] as int,
      unitPrice: fields[5] as double,
      totalPrice: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.saleId)
      ..writeByte(3)
      ..write(obj.productId)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unitPrice)
      ..writeByte(6)
      ..write(obj.totalPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
