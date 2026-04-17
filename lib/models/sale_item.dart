import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 7)
class SaleItem {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? serverId;
  @HiveField(2)
  String saleId;
  @HiveField(3)
  String productId;
  @HiveField(4)
  int quantity;
  @HiveField(5)
  double unitPrice;
  @HiveField(6)
  double totalPrice;

  SaleItem({
    String? id,
    this.serverId,
    this.saleId = '',
    this.productId = '',
    this.quantity = 0,
    this.unitPrice = 0.0,
    this.totalPrice = 0.0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverId': serverId,
        'saleId': saleId,
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  factory SaleItem.fromJson(Map<dynamic, dynamic> json) => SaleItem(
        id: json['id'],
        serverId: json['serverId'],
        saleId: json['saleId'] ?? '',
        productId: json['productId'] ?? '',
        quantity: json['quantity'] ?? 0,
        unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
        totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      );
}
