enum AppSessionMode { online, offline, guest }

class AppSession {
  final AppSessionMode mode;
  final String userId;
  final String? serverUserId;
  final String email;
  final String name;
  final DateTime authenticatedAt;

  const AppSession({
    required this.mode,
    required this.userId,
    required this.email,
    required this.name,
    required this.authenticatedAt,
    this.serverUserId,
  });

  bool get isGuest => mode == AppSessionMode.guest;
  bool get isOffline => mode == AppSessionMode.offline;
  bool get isOnline => mode == AppSessionMode.online;

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'userId': userId,
        'serverUserId': serverUserId,
        'email': email,
        'name': name,
        'authenticatedAt': authenticatedAt.toIso8601String(),
      };

  factory AppSession.fromJson(Map<dynamic, dynamic> json) {
    return AppSession(
      mode: AppSessionMode.values.firstWhere(
        (value) => value.name == json['mode'],
        orElse: () => AppSessionMode.offline,
      ),
      userId: json['userId'] as String? ?? '',
      serverUserId: json['serverUserId'] as String?,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      authenticatedAt: DateTime.parse(
        json['authenticatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
