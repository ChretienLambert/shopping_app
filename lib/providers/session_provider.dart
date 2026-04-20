import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final sessionTimeoutProvider = StateProvider<int>((ref) => 7);

final sessionExpiredProvider = StateProvider<bool>((ref) => false);

final sessionCheckProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.signOutIfExpired();
});

final sessionDaysRemainingProvider = FutureProvider<int>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getDaysUntilTimeout();
});
