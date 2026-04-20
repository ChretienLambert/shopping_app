import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/models/app_session.dart';
import 'package:shopping_app/services/session_policy.dart';

void main() {
  test('marks sessions expired after configured timeout', () {
    final expired = SessionPolicy.isExpired(
      lastActivity: DateTime(2026, 4, 1),
      now: DateTime(2026, 4, 10),
      timeoutDays: 7,
    );

    expect(expired, isTrue);
  });

  test('computes remaining session days', () {
    final remaining = SessionPolicy.remainingDays(
      lastActivity: DateTime(2026, 4, 8),
      now: DateTime(2026, 4, 10),
      timeoutDays: 7,
    );

    expect(remaining, 5);
  });

  test('offline and online sessions are treated as authenticated', () {
    final offline = AppSession(
      mode: AppSessionMode.offline,
      userId: 'local-1',
      email: 'offline@example.com',
      name: 'Offline',
      authenticatedAt: DateTime(2026, 4, 10),
    );
    final guest = AppSession(
      mode: AppSessionMode.guest,
      userId: 'guest',
      email: 'guest@local',
      name: 'Guest',
      authenticatedAt: DateTime(2026, 4, 10),
    );

    expect(SessionPolicy.canUseOfflineSession(offline), isTrue);
    expect(SessionPolicy.canUseOfflineSession(guest), isFalse);
  });
}
