import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/auth_service.dart';

final sessionTimeoutProvider = StateProvider<int>((ref) => 7);

final sessionExpiredProvider = StateProvider<bool>((ref) => false);

final sessionCheckProvider = FutureProvider<bool>((ref) async {
  final authService = AuthService();
  return await authService.signOutIfExpired();
});

final sessionDaysRemainingProvider = FutureProvider<int>((ref) async {
  final authService = AuthService();
  return await authService.getDaysUntilTimeout();
});
