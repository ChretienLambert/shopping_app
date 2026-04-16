import 'package:uuid/uuid.dart';

class Customer {
  String id;
  String? serverId; // Supabase ID
  bool isDirty;
  DateTime? lastSyncedAt;
  String name;
  String? phoneNumber;
  String? email;
  String? address;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Customer({
    String? id,
    this.serverId,
    this.isDirty = true,
    this.lastSyncedAt,
    this.name = '',
    this.phoneNumber,
    this.email,
    this.address,
    this.notes,
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
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Customer.fromJson(Map<dynamic, dynamic> json) => Customer(
        id: json['id'],
        serverId: json['serverId'],
        isDirty: json['isDirty'] ?? true,
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
        name: json['name'] ?? '',
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        address: json['address'],
        notes: json['notes'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      );
}
