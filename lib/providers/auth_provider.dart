import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/app_session.dart';
import '../services/app_config.dart';
import '../services/auth_service.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main()');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(appConfigProvider));
});

final authStateProvider = StreamProvider<supabase.AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final guestModeProvider = StateProvider<bool>((ref) => false);

final appSessionProvider = StreamProvider<AppSession?>((ref) {
  return ref.watch(authServiceProvider).sessionChanges;
});

final currentUserProvider = Provider<AppSession?>((ref) {
  return ref.watch(appSessionProvider).value ?? ref.watch(authServiceProvider).currentAppSession;
});

final sessionProvider = Provider<AppSession?>((ref) {
  return ref.watch(currentUserProvider);
});
