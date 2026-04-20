import '../models/app_session.dart';

class SessionPolicy {
  static bool isExpired({
    required DateTime lastActivity,
    required DateTime now,
    required int timeoutDays,
  }) {
    return now.difference(lastActivity).inDays >= timeoutDays;
  }

  static int remainingDays({
    required DateTime lastActivity,
    required DateTime now,
    required int timeoutDays,
  }) {
    final remaining = timeoutDays - now.difference(lastActivity).inDays;
    return remaining > 0 ? remaining : 0;
  }

  static bool canUseOfflineSession(AppSession? session) {
    return session != null &&
        (session.mode == AppSessionMode.offline ||
            session.mode == AppSessionMode.online);
  }
}
