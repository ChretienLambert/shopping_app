import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<supabase.AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final guestModeProvider = StateProvider<bool>((ref) => false);

final currentUserProvider = Provider<supabase.User?>((ref) {
  return ref.watch(authStateProvider).value?.session?.user ?? ref.watch(authServiceProvider).currentUser;
});

final sessionProvider = Provider<supabase.Session?>((ref) {
  return ref.watch(authStateProvider).value?.session ?? ref.watch(authServiceProvider).currentSession;
});
