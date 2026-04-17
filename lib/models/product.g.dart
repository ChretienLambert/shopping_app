// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 3;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String?,
      serverId: fields[1] as String?,
      isDirty: fields[2] as bool,
      lastSyncedAt: fields[3] as DateTime?,
      name: fields[4] as String,
      description: fields[5] as String,
      price: fields[6] as double,
      purchasePrice: fields[7] as double,
      stockQuantity: fields[8] as int,
      imagePath: fields[9] as String?,
      productType: fields[10] as String?,
      quality: fields[11] as String?,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
      deletedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.isDirty)
      ..writeByte(3)
      ..write(obj.lastSyncedAt)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.purchasePrice)
      ..writeByte(8)
      ..write(obj.stockQuantity)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.productType)
      ..writeByte(11)
      ..write(obj.quality)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
