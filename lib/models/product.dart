import 'package:uuid/uuid.dart';

class Product {
  String id;
  String? serverId; // Supabase ID
  bool isDirty;
  DateTime? lastSyncedAt;
  String name;
  String description;
  double price;
  double purchasePrice;
  int stockQuantity;
  String? imagePath;
  String? productType;
  String? quality;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Product({
    String? id,
    this.serverId,
    this.isDirty = true,
    this.lastSyncedAt,
    this.name = '',
    this.description = '',
    this.price = 0.0,
    this.purchasePrice = 0.0,
    this.stockQuantity = 0,
    this.imagePath,
    this.productType,
    this.quality,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverId': serverId,
        'isDirty': isDirty,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'name': name,
        'description': description,
        'price': price,
        'purchasePrice': purchasePrice,
        'stockQuantity': stockQuantity,
        'imagePath': imagePath,
        'productType': productType,
        'quality': quality,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Product.fromJson(Map<dynamic, dynamic> json) => Product(
        id: json['id'],
        serverId: json['serverId'],
        isDirty: json['isDirty'] ?? true,
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0.0).toDouble(),
        purchasePrice: (json['purchasePrice'] ?? 0.0).toDouble(),
        stockQuantity: json['stockQuantity'] ?? 0,
        imagePath: json['imagePath'],
        productType: json['productType'],
        quality: json['quality'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      );
}
