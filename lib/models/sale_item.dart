import 'package:uuid/uuid.dart';

class SaleItem {
  String id;
  String? serverId;
  String saleId;
  String productId;
  int quantity;
  double unitPrice;
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
