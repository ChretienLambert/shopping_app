import 'package:uuid/uuid.dart';

class User {
  late String id;
  String? serverId; // Supabase/Auth ID
  bool isDirty = true; // Needs sync
  DateTime? lastSyncedAt;
  late String name;
  late String email;
  String? localPasswordHash;
  String? bio;
  String? profileImageUrl;
  late DateTime createdAt;
  late DateTime updatedAt;

  User({
    String? id,
    this.serverId,
    this.isDirty = true,
    this.lastSyncedAt,
    required this.name,
    required this.email,
    this.localPasswordHash,
    this.bio,
    this.profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      id: json['id'] as String,
      serverId: json['serverId'] as String?,
      isDirty: json['isDirty'] as bool? ?? true,
      lastSyncedAt: json['lastSyncedAt'] != null 
          ? DateTime.parse(json['lastSyncedAt'] as String) 
          : null,
      name: json['name'] as String,
      email: json['email'] as String,
      localPasswordHash: json['localPasswordHash'] as String?,
      bio: json['bio'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'isDirty': isDirty,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'name': name,
      'email': email,
      'localPasswordHash': localPasswordHash,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
